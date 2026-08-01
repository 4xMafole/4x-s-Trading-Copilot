# Backend Engineer — Practical Assessment

**Name:** Erick M

**Time spent:** 7 hours

---

## Part 1



### 1.1 — Policies that need the table they protect

- At a high level, the RLS policy on staff_directory needs to read staff_directory to determine the caller's role. Reading the table causes PostgreSQL to evaluate the same policy again, which repeats indefinitely until PostgreSQL detects the recursion and rejects the query entirely, making staff_directory unreadable.

- I would keep the role in staff_directory and expose it through a narrowly scoped SECURITY DEFINER function that answers only whether the current user is an admin. The policy calls this function instead of querying staff_directory directly, which breaks the recursive evaluation while keeping authorization based on live database state. If an operator is demoted or fired at 10:14 on Tuesday, the next request reads the updated row immediately — there is no JWT or session cache to expire.

- The trade-off is that a SECURITY DEFINER function runs with elevated privileges. If it is later modified carelessly it could bypass RLS more broadly than intended, so it must be strictly limited in scope and reviewed whenever it changes.

Risk: A SECURITY DEFINER function that leaks more than the intended boolean could silently widen access to all of staff_directory, which in a financial system constitutes a privilege escalation.

Confidence: 4/5

Before committing I would verify: The function is restricted to returning only the authorization answer required by the policy and cannot be called in a way that exposes any additional rows from staff_directory.

---

### 1.2 — A colleague's proposal

- The AFTER INSERT trigger runs inside the database transaction. If the chat API takes 30 seconds, the transaction cannot commit until the trigger returns, holding locks that block every other writer — which is why the deals screen freezes. The notification for a non-existent deal occurred because the external API received the HTTP request before the database transaction rolled back; external systems cannot participate in the same transaction, so they can observe a state the database later discarded.

- Switching to fire-and-forget removes the blocking but does not solve the other two symptoms. If the process crashes after sending the HTTP request but before acknowledging success, the platform has no durable record that the notification was delivered, so it can be lost silently. There is also no persistent log of work that still needs to be done, which is why three notifications disappeared without any alert.

- I would use the Transactional Outbox pattern. The database transaction persists both the deal_book insert and an outbox record, then commits — that commit is the write-ahead durability boundary. A background worker reads committed outbox records and sends notifications independently of the transaction. This gives at-least-once delivery: notifications may be retried on failure but will never be lost and will never reference a deal that does not exist. The receiving chat platform must therefore implement idempotent processing — for example by recording processed event IDs — to absorb retries without creating duplicate notifications.

Risk: At-least-once delivery shifts the deduplication responsibility to the receiver; if the chat platform does not implement idempotency, retries will produce duplicate notifications.

Confidence: 5/5

Before committing I would verify: The outbox row is written in the same database transaction as the deal_book insert, and the background worker retries only committed outbox records and never uncommitted ones.

<img src="https://i.imgur.com/Cnrx6vN.jpeg" alt="Transaction outbox pattern" width="300" height="400">

---

### 1.3 — The same thing, booked twice

- Cause (a) is a distributed systems problem. Before inserting into deal_book, the Python service checks whether the message ID already appears in a processed_message_ids log; if it does, the service acknowledges and returns without writing. The check and the deal_book insert must be atomic — in the same database transaction — so a crash between them cannot leave a deal recorded without its ID logged, or vice versa.

- Cause (b) is a client-side problem. The Flutter app generates a stable operation ID (UUID) at the moment the operator taps Confirm. A retry reuses the same ID; a deliberate second booking generates a new one. The backend checks the operation ID against a persisted idempotency key store and returns the previous result on a match rather than inserting again. Content-based deduplication is not safe because identical deals from different intents must both be kept.

- Enforcement belongs in the backend and is anchored in the database. Flutter-only enforcement is bypassed the moment the API is called from any other client. Backend enforcement without a database unique constraint fails under concurrent load when two instances both check simultaneously and both see the key absent. The database unique constraint is the final authority.

Risk: The design depends on every client correctly distinguishing retries from new operations; a client that always generates a new UUID on retry will produce undetectable duplicates.

Confidence: 5/5

Before committing I would verify: The idempotency key and the deal_book record are written in the same transaction so neither can exist without the other after a crash.

---

### 1.4 — Only under load

- The root cause is a time-of-check / time-of-use race. The current code reads remaining_quantity, decides there is enough, then writes the reduced value. Under concurrent load two requests read the same value simultaneously, both conclude inventory is sufficient, and both write — neither aware the other already consumed from it. remaining_quantity goes negative as a result. This reproduces only between 09:00 and 09:30 because that is when concurrent requests on the same popular lots are frequent enough to close the race window.

- The fix I would ship is SELECT ... FOR UPDATE on the lot row before the check, serializing the read-check-write sequence per lot. I would also add a CHECK constraint enforcing remaining_quantity >= 0 as a final database guard. The alternative I rejected is optimistic locking with a version column — correct but it produces heavy retry churn on popular lots, worsening latency during the exact window where the problem occurs.

- To test: start two concurrent transactions that both read the same lot with sufficient quantity, pause before either writes, then let both complete. Assert that remaining_quantity >= 0 and that total allocated does not exceed the original quantity. Without the lock both proceed and the assertion fails; with FOR UPDATE the second transaction blocks on the first and the assertion passes.

Risk: FOR UPDATE serializes all writes to a single lot; if one popular lot receives very high concurrent demand it becomes a bottleneck — partitioning high-demand lots into sub-lots reduces contention but adds schema complexity.

Confidence: 4/5

Before committing I would verify: The SELECT FOR UPDATE and the UPDATE to remaining_quantity occur within the same database transaction so the lock is held continuously between the check and the write.

---

### 1.5 — Cents, grams, and ounces

- I would store the agreed FX rate as NUMERIC(20,8) in a dedicated fx_rates table keyed by currency pair and the exact fixing timestamp, separate from the DECIMAL(18,4) columns used for monetary amounts. The deal_book row holds a foreign key to the exact fx_rates record agreed at the fixing date, the raw notional in USD per troy ounce, and the contract quantity in its native unit. The settlement amount in the second currency is a derived value, computed at reporting time from those stored inputs rather than stored itself, so there is a single source of truth per trade and no risk of stored and derived figures drifting apart.

- Rounding happens exactly once, at display or statement generation, using the currency's standard rule (half-up to 2 decimal places for USD). Each line item is computed from unrounded stored values and rounded independently. If the sum of rounded line items differs from the rounded grand total by one or two cents — an inevitable result of distributed rounding — I apply a penny adjustment to the largest line item, recorded as a named reconciliation entry rather than silently altering any stored value, so any historical statement can be reproduced from stored data.

- Three dates exist per trade: trade date (deal agreed), fixing date (FX rate officially set), and settlement date (money moves). The FX rate that governs the settlement value is the one recorded at the fixing date, not the trade date and not the settlement date. Storing an fx_rate_id foreign key on the deal_book row ties the settlement calculation permanently to the agreed rate so it is reproducible regardless of later market movements.

Risk: Computing settlement amounts at query time rather than storing them adds join complexity and means any change to the derivation logic retroactively affects all historical calculations unless the stored inputs are fully immutable.

Confidence: 4/5

Before committing I would verify: The penny adjustment is recorded as a named audit line so the statement can be reconstructed exactly from stored data without relying on any implicit rounding behavior.

---

### 1.6 — "What did the report say in April?"

- There are two distinct kinds of "when": transaction time (when the database row was written) and valid time (the real-world period the data describes). The current design, which stores only current state and an updated_at column, collapses both into one. When a row is corrected, the previous state is lost permanently. The system cannot answer "what did we know on 2 April" because it records only what is true now, not what was true at a given moment in the past.

- A correction and a new business event are fundamentally different. Corrections may require restating prior periods; new events belong only in the period they occurred. A design that treats both as in-place row updates loses that distinction. I would add an append-only history table recording the previous values, change type (correction, adjustment, or new event), actor, and transaction timestamp. The deal_book row holds current state; the history table holds the auditable timeline.

- With append-only history, answering the April question is one query: filter history rows whose transaction timestamp is on or before 2 April for the March period. The 1.42M was correct at that snapshot; 1.39M reflects post-April changes. The history table shows which deal_book rows changed, by whom, and whether each was a correction or a new business event — both figures are right for their respective moments.

Risk: Append-only history grows storage proportionally to write volume and requires every write path to consistently append rather than update — a single path that bypasses this breaks the audit trail silently.

Confidence: 4/5

Before committing I would verify: Every code path and migration that touches deal_book rows also writes a history record in the same transaction, with no exceptions.

---

## Part 2


### 2.3 — Monday, 08:40

- I query the database directly — not through the application — to check whether the records exist. This separates "data is absent" from "data exists but is hidden." If rows are present, I inspect the policies on deal_book for any predicate that could filter that customer's rows, and check whether the customer's entry in staff_directory has a NULL or unexpected value that a policy would evaluate as false. If rows are absent, I check the history table or audit log for deletes, then the Python service logs for messages that failed to write.

- To distinguish "deleted" from "hidden": if the history table shows a delete event for that customer and date range, the data was actively removed. If the rows exist in the database but the application does not show them, the cause is a visibility or policy issue. I look for any policy change, schema migration, or staff_directory update deployed over the weekend that could have altered the effective filter.

- In the first 20 minutes I do not restart any service, attempt data recovery, or contact the customer. Restarting destroys in-memory evidence; recovery before diagnosis risks a second incident. Every diagnostic query runs read-only against a replica. The goal is a confirmed scope and credible status for operations when the market opens, not a fix.

Risk: Time pressure increases the chance of misreading a query result or drawing the wrong conclusion; every finding should be cross-checked against one independent source before acting on it.

Confidence: 4/5

Before committing I would verify: All diagnostic queries are confirmed read-only and run against a replica so the investigation cannot accidentally modify production data under pressure.

---

### 2.4 — The key in the repo

- The first action is to revoke or rotate the key immediately. Notification, audit, and cleanup operate on past exposure — only rotation stops future exposure. Every minute the key remains valid is a minute anyone with repository access can use it. I disable it at the provider first if that is faster, then issue a replacement and deploy it to all dependent services.

- After rotation I audit the provider's access logs for the three-month window, looking for requests not attributable to known internal IPs or service accounts. I check git history to confirm exactly when the key was committed and whether it appeared in any pull request, fork, or CI log. I notify the security team with a timeline so they can assess any breach disclosure obligation.

- I remove the key from git history with a rewrite tool, force-push to all remotes, and notify contributors to re-clone. Going forward I add pre-commit secrets scanning and move credentials to a secrets manager.

Risk: Rotating the key breaks any service currently using it; knowing every consumer in advance is a prerequisite or rotation causes an outage alongside the security response.

Confidence: 5/5

Before committing I would verify: The new key is live and verified in all dependent services before the old key is fully disabled, so rotation does not cause a service interruption.

---

## Part 3


### 3.1 — Evaluating a claim

- I disagree. SECURITY BYPASS disables RLS for that context entirely — not just for the self-reference. Any code path through the bypassed policy reads every row in staff_directory, trading recursion for privilege escalation in a money-movement system.

- `rls.allow_self_reference = on` is not a PostgreSQL parameter in any current release. Recommending non-existent settings is a credibility problem; applying unverified configuration to a financial production database is a risk in itself.

- What I would use: the SECURITY DEFINER function from 1.1, scoped to return only whether the caller is an admin, audited to confirm it exposes no additional rows from staff_directory.

Risk: Applying this recommendation grants all authenticated sessions unrestricted read access to staff_directory, violating least privilege.

---

### 3.2 — AI disclosure

I used an AI assistant to help structure, review, and stress-test my reasoning across all Part 1 and Part 2 answers. My process was to reason through each answer myself first, then use the assistant to challenge my logic, catch gaps, and confirm PostgreSQL-specific mechanics I described.

One concrete case where the assistant was imprecise: on 1.4, it initially suggested serializable isolation as a sufficient fix without noting that serializable only prevents the anomaly if every concurrent transaction also uses that isolation level — in a mixed-isolation system where connections default to READ COMMITTED, serializable on one transaction does not protect against a READ COMMITTED reader on the other side. It also did not initially flag that the SELECT and the UPDATE must be in the same transaction for the FOR UPDATE lock to be held continuously between check and write. I caught both gaps by walking through the transaction lifecycle myself and added the clarifications directly to my answer.

For 3.4 AI was used only to help articulate and structure it clearly — that answer is from direct personal experience.

---

### 3.3 — The contradiction

- Scenario 1.5 contradicts itself. It requires both that line items are rounded independently and that their sum equals the printed total exactly.

- Independent rounding makes exact equality impossible: two $1.235 lines round to $2.48 combined, but the unrounded total rounds to $2.47. No rounding rule eliminates this without an explicit adjustment entry.

- I assumed the grand total derives from unrounded values and rounds once at output, with any residual as a named reconciliation entry. I would confirm this with finance before building.

Risk: If finance requires no adjustment entries whatsoever, a different rounding model is needed.

---

### 3.4 — Something you actually broke

System: LocoGame — multi-tenant leaderboard platform, ~3 lounges in production, Supabase/PostgreSQL backend with RLS.

**Symptom:** Managers in Lounge A could see match records and player stats belonging to Lounge B. Silent data leak — no errors, no crashes, just wrong data in leaderboards.

**Root Cause:** The `matches_all_member` RLS policy correctly checks `auth.uid()` against `memberships`. But the frontend never filtered queries by `lounge_id` on the active session — it trusted RLS to scope everything. A user legitimately belonging to two lounges would get rows from both, because RLS *permitted* it. That's correct behaviour; the bug was the missing client-side filter.

I only caught this late because my test user was seeded into every lounge, so all my local RLS validation passed cleanly.

**Discovery time:** ~4 hours. Found it when a real owner reported seeing unfamiliar player names in their match history.

**Fix:** Added mandatory `.eq('lounge_id', activeLoungeId)` to every Supabase query client-side. Also added a server-side function enforcing lounge context explicitly so the client can't forget.

**What I'd do differently:** Never seed a super-member test user. Write RLS tests using `set_config('request.jwt.claims', ...)` with single-lounge users per test case — before anything ships.

---

Prepared with attention to operational safety.
