"""
LocoTrader PDF Generator - Professional Edition
Generates branded PDFs matching the LocoTrader design system.

Design system:
- Primary: Blue #3B82F6 (brand blue from logo)
- Navy: #0F172A (headers, dark elements)
- Slate: #1E293B (secondary text)
- Emerald: #10B981 (success/accent)
- Background: White (PDF-optimized)
- Font: Helvetica (closest to Inter for PDFs)
"""

import os
import re
from fpdf import FPDF

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MARKETING_DIR = os.path.join(BASE_DIR, "marketing")
INVESTOR_DIR = os.path.join(BASE_DIR, "investor-kit")
PDF_OUTPUT_DIR = os.path.join(BASE_DIR, "pdf-exports")

# LocoTrader Design Tokens
BLUE = (59, 130, 246)
NAVY = (15, 23, 42)
SLATE = (30, 41, 59)
SLATE_LIGHT = (71, 85, 105)
EMERALD = (16, 185, 129)
WHITE = (255, 255, 255)
GRAY_50 = (248, 250, 252)
GRAY_100 = (241, 245, 249)
GRAY_200 = (226, 232, 240)
GRAY_400 = (148, 163, 184)
BLACK = (0, 0, 0)


class LocoTraderPDF(FPDF):
    """Professional PDF generator following LocoTrader design system."""

    def __init__(self, title="", doc_type=""):
        super().__init__()
        self.doc_title = title
        self.doc_type = doc_type
        self.set_auto_page_break(auto=True, margin=25)
        self.set_margins(left=20, top=20, right=20)
        self.is_cover = False

    def header(self):
        if self.is_cover or self.page_no() == 1:
            return
        self.set_draw_color(*BLUE)
        self.set_line_width(0.8)
        self.line(20, 12, 190, 12)
        self.set_y(14)
        self.set_font("Helvetica", "", 7.5)
        self.set_text_color(*SLATE_LIGHT)
        self.cell(85, 5, "LOCOTRADER  |  " + self.doc_type.upper())
        self.cell(85, 5, self.doc_title, align="R")
        self.ln(10)

    def footer(self):
        if self.is_cover:
            return
        self.set_y(-18)
        self.set_draw_color(*GRAY_200)
        self.set_line_width(0.3)
        self.line(20, self.get_y(), 190, self.get_y())
        self.ln(3)
        self.set_font("Helvetica", "", 7)
        self.set_text_color(*GRAY_400)
        self.cell(85, 5, "Confidential  |  LocoTrader  |  July 2026")
        self.cell(85, 5, str(self.page_no()), align="R")

    def add_cover_page(self, title, subtitle="", category=""):
        self.is_cover = True
        self.add_page()

        # Navy header block
        self.set_fill_color(*NAVY)
        self.rect(0, 0, 210, 100, "F")

        # Blue accent bar
        self.set_fill_color(*BLUE)
        self.rect(0, 100, 210, 3, "F")

        # Brand name on navy
        self.set_y(20)
        self.set_x(25)
        self.set_font("Helvetica", "B", 11)
        self.set_text_color(*WHITE)
        self.cell(50, 6, "LOCOTRADER")
        self.ln(6)
        self.set_x(25)
        self.set_font("Helvetica", "", 8)
        self.set_text_color(*GRAY_400)
        self.cell(80, 5, "Trade Your Rules. Not Your Feelings.")
        self.ln(15)

        # Category badge
        if category:
            self.set_x(25)
            self.set_font("Helvetica", "", 8)
            self.set_text_color(*BLUE)
            self.cell(80, 5, category.upper())
            self.ln(5)

        # Title on navy
        self.set_x(25)
        font_size = 26 if len(title) <= 30 else 22
        self.set_font("Helvetica", "B", font_size)
        self.set_text_color(*WHITE)
        self.multi_cell(160, 12, title)

        # Subtitle below bar
        self.set_y(115)
        self.set_x(25)
        if subtitle:
            self.set_font("Helvetica", "", 12)
            self.set_text_color(*SLATE)
            self.multi_cell(160, 7, subtitle)

        # Bottom metadata
        self.set_y(240)
        self.set_x(25)
        self.set_font("Helvetica", "", 9)
        self.set_text_color(*GRAY_400)
        self.cell(80, 5, "Prepared: July 2026")
        self.cell(80, 5, "Status: Confidential", align="R")
        self.ln(6)
        self.set_x(25)
        self.cell(80, 5, "Founder: Erick Mafole")
        self.cell(80, 5, "Location: Dar es Salaam, Tanzania", align="R")

        # Bottom accent
        self.set_fill_color(*BLUE)
        self.rect(0, 287, 210, 10, "F")

        self.is_cover = False

    def add_toc_page(self, sections):
        self.add_page()
        self.set_font("Helvetica", "B", 18)
        self.set_text_color(*NAVY)
        self.cell(170, 12, "Contents")
        self.ln(12)
        self.set_draw_color(*BLUE)
        self.set_line_width(0.5)
        self.line(20, self.get_y(), 80, self.get_y())
        self.ln(10)

        for i, (section_title, _) in enumerate(sections, 1):
            self.set_font("Helvetica", "B", 9)
            self.set_text_color(*BLUE)
            self.cell(10, 8, f"{i:02d}")
            self.set_font("Helvetica", "", 11)
            self.set_text_color(*NAVY)
            self.cell(160, 8, section_title)
            self.ln(8)
            if i < len(sections):
                self.set_draw_color(*GRAY_200)
                self.set_line_width(0.1)
                self.line(20, self.get_y(), 190, self.get_y())
                self.ln(2)

    def add_section_divider(self, title, number=None):
        self.add_page()
        self.set_fill_color(*BLUE)
        self.rect(20, 35, 45, 2, "F")
        self.set_y(42)
        if number:
            self.set_font("Helvetica", "B", 9)
            self.set_text_color(*BLUE)
            self.cell(170, 6, f"SECTION {number:02d}")
            self.ln(6)
        self.set_font("Helvetica", "B", 20)
        self.set_text_color(*NAVY)
        self.multi_cell(170, 10, title)
        self.ln(8)

    def render_markdown(self, md_content):
        """Render markdown content to professionally styled PDF."""
        lines = md_content.split("\n")
        in_code_block = False
        in_table = False
        skip_first_h1 = True

        for line in lines:
            self.set_x(20)

            if self.get_y() > 262:
                self.add_page()

            if not line.strip() and not in_code_block:
                self.ln(2)
                continue

            # Code blocks
            if line.strip().startswith("```"):
                in_code_block = not in_code_block
                if not in_code_block:
                    self.ln(4)
                else:
                    self.ln(2)
                continue

            if in_code_block:
                self._render_code_line(line)
                continue

            # Tables
            if "|" in line and line.strip().startswith("|"):
                if re.match(r"^\|[\s\-:|]+\|$", line.strip()):
                    continue
                cells = [c.strip() for c in line.strip().split("|")[1:-1]]
                if not in_table:
                    in_table = True
                    self._render_table_header(cells)
                else:
                    self._render_table_row(cells)
                continue
            elif in_table:
                in_table = False
                self.ln(5)

            # Headings
            if line.startswith("# "):
                if skip_first_h1:
                    skip_first_h1 = False
                    continue
                self._render_h1(line[2:])
            elif line.startswith("## "):
                self._render_h2(line[3:])
            elif line.startswith("### "):
                self._render_h3(line[4:])
            elif line.startswith("#### "):
                self._render_h4(line[5:])
            elif line.startswith("> "):
                self._render_blockquote(line[2:])
            elif line.strip().startswith("- ") or line.strip().startswith("* "):
                self._render_bullet(line)
            elif re.match(r"^\s*\d+[\.\)]\s", line):
                self._render_numbered(line)
            elif line.startswith("---"):
                self._render_divider()
            elif line.strip().startswith("**") and line.strip().endswith("**"):
                self._render_bold_line(line)
            else:
                self._render_paragraph(line)

    def _render_h1(self, text):
        self.ln(8)
        self.set_font("Helvetica", "B", 18)
        self.set_text_color(*NAVY)
        self.multi_cell(170, 9, self._clean(text))
        self.set_fill_color(*BLUE)
        self.rect(20, self.get_y() + 1, 35, 1.5, "F")
        self.ln(6)

    def _render_h2(self, text):
        self.ln(7)
        self.set_font("Helvetica", "B", 14)
        self.set_text_color(*NAVY)
        self.multi_cell(170, 7.5, self._clean(text))
        self.ln(2)

    def _render_h3(self, text):
        self.ln(5)
        self.set_font("Helvetica", "B", 11.5)
        self.set_text_color(*SLATE)
        self.multi_cell(170, 6.5, self._clean(text))
        self.ln(1)

    def _render_h4(self, text):
        self.ln(4)
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(*SLATE)
        self.multi_cell(170, 6, self._clean(text))
        self.ln(1)

    def _render_blockquote(self, text):
        y_start = self.get_y()
        self.set_x(28)
        self.set_font("Helvetica", "I", 9.5)
        self.set_text_color(*SLATE_LIGHT)
        self.multi_cell(155, 5.5, self._clean(text))
        y_end = self.get_y()
        # Blue left border
        self.set_fill_color(*BLUE)
        self.rect(22, y_start, 2, y_end - y_start, "F")
        self.set_text_color(*BLACK)
        self.ln(1)

    def _render_bullet(self, line):
        indent_level = (len(line) - len(line.lstrip())) // 2
        text = self._clean(line.strip().lstrip("-*").strip())

        left_pad = 24 + (indent_level * 7)
        bullet_y = self.get_y() + 1.8

        # Draw bullet
        if indent_level == 0:
            self.set_fill_color(*BLUE)
            self.rect(left_pad, bullet_y, 2.2, 2.2, "F")
        else:
            self.set_draw_color(*GRAY_400)
            self.set_line_width(0.4)
            self.rect(left_pad + 0.3, bullet_y + 0.3, 1.6, 1.6, "D")

        text_x = left_pad + 5
        self.set_x(text_x)
        self.set_font("Helvetica", "", 9.5)
        self.set_text_color(*SLATE)
        avail = 188 - text_x
        if avail < 50:
            avail = 50
        self.multi_cell(avail, 5, text)
        self.set_text_color(*BLACK)

    def _render_numbered(self, line):
        text = self._clean(line.strip())
        self.set_x(24)
        self.set_font("Helvetica", "", 9.5)
        self.set_text_color(*SLATE)
        self.multi_cell(162, 5, text)
        self.set_text_color(*BLACK)

    def _render_code_line(self, line):
        self.set_fill_color(*GRAY_100)
        clean = self._clean(line)
        if len(clean) > 88:
            clean = clean[:88] + "..."
        self.set_font("Courier", "", 7.5)
        self.set_text_color(*SLATE)
        self.set_x(22)
        self.cell(166, 4.5, "  " + clean, fill=True)
        self.ln(4.5)
        self.set_text_color(*BLACK)

    def _render_table_header(self, cells):
        if not cells:
            return
        self.ln(3)
        widths = self._calc_col_widths(cells)
        if not widths:
            return

        self.set_fill_color(*NAVY)
        self.set_text_color(*WHITE)
        self.set_font("Helvetica", "B", 8)
        self.set_x(20)

        for i, cell in enumerate(cells):
            if i >= len(widths):
                break
            text = self._clean(cell)
            max_c = max(int(widths[i] / 2.1), 4)
            if len(text) > max_c:
                text = text[:max_c - 1] + "."
            self.cell(widths[i], 7, " " + text, border=0, fill=True)
        self.ln(7)
        self.set_text_color(*BLACK)

    def _render_table_row(self, cells):
        if not cells:
            return
        widths = self._calc_col_widths(cells)
        if not widths:
            return

        self.set_fill_color(*GRAY_50)
        self.set_font("Helvetica", "", 8)
        self.set_text_color(*SLATE)
        self.set_x(20)

        for i, cell in enumerate(cells):
            if i >= len(widths):
                break
            text = self._clean(cell)
            max_c = max(int(widths[i] / 2.1), 4)
            if len(text) > max_c:
                text = text[:max_c - 1] + "."
            self.cell(widths[i], 6, " " + text, border=0, fill=True)
        self.ln(6)
        self.set_draw_color(*GRAY_200)
        self.set_line_width(0.1)
        self.line(20, self.get_y(), 190, self.get_y())
        self.set_text_color(*BLACK)

    def _calc_col_widths(self, cells):
        n = len(cells)
        if n == 0:
            return []
        total = 170
        if n > 7:
            self.set_font("Helvetica", "", 8)
            self.set_text_color(*SLATE)
            text = "  |  ".join(self._clean(c) for c in cells[:6])
            self.multi_cell(170, 5, text)
            return []
        if n == 1:
            return [total]
        elif n == 2:
            return [total * 0.45, total * 0.55]
        elif n == 3:
            return [total * 0.35, total * 0.32, total * 0.33]
        elif n == 4:
            return [total * 0.28, total * 0.24, total * 0.24, total * 0.24]
        elif n == 5:
            return [total * 0.24, total * 0.19, total * 0.19, total * 0.19, total * 0.19]
        elif n == 6:
            return [total * 0.2, total * 0.16, total * 0.16, total * 0.16, total * 0.16, total * 0.16]
        else:
            return [total / n] * n

    def _render_divider(self):
        self.ln(4)
        self.set_draw_color(*GRAY_200)
        self.set_line_width(0.3)
        self.line(20, self.get_y(), 190, self.get_y())
        self.ln(6)

    def _render_bold_line(self, line):
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(*NAVY)
        text = self._clean(line.strip().strip("*"))
        self.multi_cell(170, 6, text)
        self.set_text_color(*BLACK)
        self.ln(1)

    def _render_paragraph(self, line):
        text = self._clean(line)
        if not text.strip():
            return
        self.set_font("Helvetica", "", 9.5)
        self.set_text_color(*SLATE)
        self.multi_cell(170, 5, text)
        self.set_text_color(*BLACK)

    def _clean(self, text):
        """Remove markdown formatting and encode for PDF."""
        text = re.sub(r"\*\*(.+?)\*\*", r"\1", text)
        text = re.sub(r"\*(.+?)\*", r"\1", text)
        text = re.sub(r"__(.+?)__", r"\1", text)
        text = re.sub(r"_(.+?)_", r"\1", text)
        text = re.sub(r"\[(.+?)\]\(.+?\)", r"\1", text)
        text = re.sub(r"`(.+?)`", r"\1", text)
        # Emoji replacements
        replacements = {
            "\u2705": "[OK]", "\u274c": "[X]", "\u26a0\ufe0f": "[!]",
            "\ud83d\udea7": "[!]", "\ud83c\udfaf": ">", "\ud83d\ude80": "",
            "\ud83d\udcca": "", "\ud83d\udcb0": "", "\ud83d\udd12": "",
            "\ud83d\udcf1": "", "\ud83e\udde0": "", "\ud83e\uddee": "",
            "\ud83d\udcdd": "", "\ud83d\udea8": "", "\ud83d\udd34": "",
            "\ud83d\udfe1": "", "\ud83d\udfe2": "", "\ud83d\udcac": "",
            "\u2b50": "*", "\ud83c\udfc6": "", "\u2190": "<-",
            "\u2192": "->", "\u2194": "<->", "\u2191": "^",
            "\u2193": "v", "\u25cf": "*", "\u2014": " - ",
            "\u2013": "-", "\u2265": ">=", "\u2264": "<=",
            "\u2260": "!=", "\u00d7": "x", "\u2022": "-",
            "\u25cb": "o", "\ud83e\udd47": "1.", "\ud83e\udd48": "2.",
            "\ud83e\udd49": "3.", "\ud83d\udce2": "", "\ud83d\udca1": "",
        }
        for k, v in replacements.items():
            text = text.replace(k, v)
        text = text.encode("latin-1", errors="replace").decode("latin-1")
        return text


def read_markdown(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        return f.read()


def generate_single_pdf(md_file, output_path, title, subtitle="", doc_type=""):
    content = read_markdown(md_file)
    pdf = LocoTraderPDF(title=title, doc_type=doc_type)
    pdf.add_cover_page(title, subtitle, doc_type)
    pdf.add_page()
    pdf.render_markdown(content)
    pdf.output(output_path)
    size_kb = os.path.getsize(output_path) / 1024
    print(f"  [OK] {os.path.basename(output_path):45s} ({size_kb:.1f} KB)")


def generate_combined_pdf(md_files, output_path, title, subtitle="", doc_type=""):
    pdf = LocoTraderPDF(title=title, doc_type=doc_type)
    pdf.add_cover_page(title, subtitle, doc_type)
    pdf.add_toc_page(md_files)

    for i, (md_file, section_title) in enumerate(md_files, 1):
        if not os.path.exists(md_file):
            print(f"  [SKIP] {md_file} not found")
            continue
        content = read_markdown(md_file)
        pdf.add_section_divider(section_title, number=i)
        pdf.render_markdown(content)

    pdf.output(output_path)
    size_kb = os.path.getsize(output_path) / 1024
    print(f"  [OK] {os.path.basename(output_path):45s} ({size_kb:.1f} KB)")


def main():
    marketing_pdf_dir = os.path.join(PDF_OUTPUT_DIR, "marketing")
    investor_pdf_dir = os.path.join(PDF_OUTPUT_DIR, "investor-kit")
    os.makedirs(marketing_pdf_dir, exist_ok=True)
    os.makedirs(investor_pdf_dir, exist_ok=True)

    print()
    print("  " + "=" * 56)
    print("  LOCOTRADER  |  Professional PDF Generation")
    print("  " + "=" * 56)

    # Marketing Hub
    print("\n  MARKETING HUB")
    print("  " + "-" * 56)

    marketing_files = [
        ("brand-positioning.md", "Brand Positioning",
         "Identity, voice guidelines, and messaging framework"),
        ("app-store-listing.md", "App Store Listing",
         "iOS & Android store copy, ASO keywords, and screenshot strategy"),
        ("content-calendar.md", "Content Calendar",
         "12-week content plan optimized for solo founder output"),
        ("go-to-market.md", "Go-To-Market Strategy",
         "Phase-based launch plan with channels, targets, and success criteria"),
        ("metrics.md", "Metrics & KPIs",
         "Tracking framework with industry benchmarks and review templates"),
        ("outreach-templates.md", "Outreach Templates",
         "Copy-paste templates for influencers, communities, and partnerships"),
        ("social-media-strategy.md", "Social Media Strategy",
         "Platform playbook, content pillars, and growth tactics"),
        ("competitor-analysis.md", "Competitor Analysis",
         "Market landscape, feature matrix, and positioning gaps"),
        ("pricing-strategy.md", "Pricing Strategy",
         "Revenue model analysis and post-launch monetization plan"),
        ("landing-page-copy.md", "Landing Page Copy",
         "Conversion-optimized website copy blocks"),
    ]

    for filename, title, subtitle in marketing_files:
        md_path = os.path.join(MARKETING_DIR, filename)
        if os.path.exists(md_path):
            pdf_path = os.path.join(marketing_pdf_dir, filename.replace(".md", ".pdf"))
            generate_single_pdf(md_path, pdf_path, title, subtitle, "Marketing Hub")

    print()
    combined_marketing = [
        (os.path.join(MARKETING_DIR, f), t) for f, t, _ in marketing_files
    ]
    generate_combined_pdf(
        combined_marketing,
        os.path.join(marketing_pdf_dir, "LocoTrader-Marketing-Hub-Complete.pdf"),
        "Marketing Hub",
        "Complete Strategy, Positioning, and Launch Materials",
        "LocoTrader"
    )

    # Investor Kit
    print(f"\n  INVESTOR KIT")
    print("  " + "-" * 56)

    investor_files = [
        ("executive-summary.md", "Executive Summary",
         "One-page overview for investor conversations"),
        ("pitch-deck-script.md", "Pitch Deck & Script",
         "14-slide narrative with word-for-word delivery notes"),
        ("financial-projections.md", "Financial Projections",
         "3-year revenue model with unit economics and scenarios"),
        ("investor-faq.md", "Investor FAQ",
         "Data-backed answers to common pre-seed questions"),
        ("one-pager.md", "One-Pager",
         "Visual single-page summary for quick reference"),
    ]

    for filename, title, subtitle in investor_files:
        md_path = os.path.join(INVESTOR_DIR, filename)
        if os.path.exists(md_path):
            pdf_path = os.path.join(investor_pdf_dir, filename.replace(".md", ".pdf"))
            generate_single_pdf(md_path, pdf_path, title, subtitle, "Investor Kit")

    print()
    combined_investor = [
        (os.path.join(INVESTOR_DIR, f), t) for f, t, _ in investor_files
    ]
    generate_combined_pdf(
        combined_investor,
        os.path.join(investor_pdf_dir, "LocoTrader-Investor-Kit-Complete.pdf"),
        "Investor Kit",
        "Pre-Seed  |  $50K - $150K  |  SAFE Note",
        "LocoTrader"
    )

    print()
    print("  " + "=" * 56)
    print(f"  Output: {PDF_OUTPUT_DIR}")
    print("  " + "=" * 56)
    print()


if __name__ == "__main__":
    main()
