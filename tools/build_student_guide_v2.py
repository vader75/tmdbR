from pathlib import Path
import csv

from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table, TableStyle,
    PageBreak, Image, Flowable, HRFlowable, KeepTogether
)

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "tmp" / "pdfs" / "student_guide_v2" / "assets"
OUT = ROOT / "output" / "pdf" / "tmdbR_student_guide.pdf"

MIDNIGHT = HexColor("#06283A")
NAVY = HexColor("#0B3349")
TEAL = HexColor("#11B8B2")
SKY = HexColor("#39C5E6")
ORANGE = HexColor("#EF8354")
CREAM = HexColor("#FFF8EE")
PALE = HexColor("#EAF8F7")
MIST = HexColor("#F3F7F8")
INK = HexColor("#173042")
MUTED = HexColor("#607B87")
LINE = HexColor("#C8D9DE")
WHITE = colors.white


def fonts():
    paths = {
        "Guide": "/System/Library/Fonts/Supplemental/Arial.ttf",
        "GuideBold": "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "GuideMono": "/System/Library/Fonts/SFNSMono.ttf",
    }
    for name, path in paths.items():
        if Path(path).exists():
            pdfmetrics.registerFont(TTFont(name, path))
    registered = pdfmetrics.getRegisteredFontNames()
    return (
        "Guide" if "Guide" in registered else "Helvetica",
        "GuideBold" if "GuideBold" in registered else "Helvetica-Bold",
        "GuideMono" if "GuideMono" in registered else "Courier",
    )


REG, BOLD, MONO = fonts()


class GuideDoc(BaseDocTemplate):
    def __init__(self, filename):
        super().__init__(filename, pagesize=A4, leftMargin=18 * mm, rightMargin=18 * mm,
                         topMargin=22 * mm, bottomMargin=17 * mm,
                         title="tmdbR: From API access to first-year statistics",
                         author="COMP3020")
        frame = Frame(self.leftMargin, self.bottomMargin, self.width, self.height, id="body")
        self.addPageTemplates(PageTemplate(id="main", frames=[frame], onPage=self.page_art))

    def page_art(self, c: canvas.Canvas, doc):
        n = c.getPageNumber()
        c.saveState()
        if n == 1:
            c.setFillColor(MIDNIGHT); c.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
            c.setFillColor(NAVY); c.circle(A4[0] - 15 * mm, A4[1] - 18 * mm, 42 * mm, fill=1, stroke=0)
            c.setFillColor(TEAL); c.circle(A4[0] - 1 * mm, A4[1] - 2 * mm, 22 * mm, fill=1, stroke=0)
            c.setStrokeColor(SKY); c.setLineWidth(1.2)
            for i in range(7):
                c.line(0, 24 * mm + i * 6 * mm, 58 * mm - i * 3 * mm, 24 * mm + i * 6 * mm)
        else:
            c.setFillColor(MIDNIGHT); c.rect(0, A4[1] - 11 * mm, A4[0], 11 * mm, fill=1, stroke=0)
            c.setFillColor(TEAL); c.rect(0, A4[1] - 11 * mm, 7 * mm, 11 * mm, fill=1, stroke=0)
            c.setFont(BOLD, 7.8); c.setFillColor(WHITE)
            c.drawString(18 * mm, A4[1] - 7.1 * mm, "COMP3020  /  tmdbR STUDENT GUIDE")
            c.setStrokeColor(LINE); c.line(18 * mm, 12 * mm, A4[0] - 18 * mm, 12 * mm)
            c.setFont(REG, 7.2); c.setFillColor(MUTED)
            c.drawString(18 * mm, 7.5 * mm, "tmdbR 0.2.0  |  Interface checked 8 August 2026")
            c.drawRightString(A4[0] - 18 * mm, 7.5 * mm, f"{n} / 13")
        c.restoreState()


ss = getSampleStyleSheet()
ss.add(ParagraphStyle(name="Eyebrow", fontName=BOLD, fontSize=9, leading=12,
                      textColor=TEAL, spaceAfter=6, tracking=1.3))
ss.add(ParagraphStyle(name="CoverTitle2", fontName=BOLD, fontSize=31, leading=34,
                      textColor=WHITE, spaceAfter=13))
ss.add(ParagraphStyle(name="CoverDeck2", fontName=REG, fontSize=13, leading=19,
                      textColor=HexColor("#D6EAEE"), spaceAfter=8))
ss.add(ParagraphStyle(name="H1v2", fontName=BOLD, fontSize=23, leading=27,
                      textColor=MIDNIGHT, spaceAfter=5))
ss.add(ParagraphStyle(name="Deck2", fontName=REG, fontSize=10.3, leading=14.5,
                      textColor=MUTED, spaceAfter=9))
ss.add(ParagraphStyle(name="H2v2", fontName=BOLD, fontSize=13, leading=16,
                      textColor=NAVY, spaceBefore=7, spaceAfter=4))
ss.add(ParagraphStyle(name="Body2", fontName=REG, fontSize=8.9, leading=12.6,
                      textColor=INK, spaceAfter=4))
ss.add(ParagraphStyle(name="Small2", fontName=REG, fontSize=7.3, leading=9.5,
                      textColor=MUTED))
ss.add(ParagraphStyle(name="Code2", fontName=MONO, fontSize=7.4, leading=10.2,
                      textColor=INK, backColor=HexColor("#F0F6F7"),
                      borderColor=TEAL, borderWidth=0.7, borderPadding=7,
                      spaceBefore=14, spaceAfter=7))
ss.add(ParagraphStyle(name="CodeCompact", parent=ss["Code2"], fontSize=6.6,
                      leading=8.1, borderPadding=6))
ss.add(ParagraphStyle(name="CardTitle", fontName=BOLD, fontSize=10, leading=12,
                      textColor=NAVY, spaceAfter=3))
ss.add(ParagraphStyle(name="TableH2", fontName=BOLD, fontSize=7.5, leading=9,
                      textColor=WHITE))
ss.add(ParagraphStyle(name="TableB2", fontName=REG, fontSize=7.3, leading=9.3,
                      textColor=INK))


def P(text, style="Body2"):
    return Paragraph(text, ss[style])


def code(text):
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return Paragraph(text.replace(" ", "&nbsp;").replace("\n", "<br/>"), ss["Code2"])


def compact_code(text):
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    return Paragraph(text.replace(" ", "&nbsp;").replace("\n", "<br/>"), ss["CodeCompact"])


def fn_list(names):
    return ", ".join(f"<font name='GuideMono'>{name}()</font>" for name in names)


def heading(section, title, deck):
    return [P(section.upper(), "Eyebrow"), P(title, "H1v2"), P(deck, "Deck2")]


def callout(title, body, tone="teal"):
    color = TEAL if tone == "teal" else ORANGE
    bg = PALE if tone == "teal" else CREAM
    t = Table([[P(title, "CardTitle"), P(body, "Body2")]], colWidths=[38 * mm, 128 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), bg), ("BOX", (0, 0), (-1, -1), 0.7, color),
        ("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 7),
        ("RIGHTPADDING", (0, 0), (-1, -1), 7), ("TOPPADDING", (0, 0), (-1, -1), 7),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
    ]))
    return t


def bullets(items):
    return [P(f"<font color='#11B8B2'><b>●</b></font>&nbsp;&nbsp;{x}") for x in items]


def table(headers, rows, widths):
    data = [[P(x, "TableH2") for x in headers]] + [[P(x, "TableB2") for x in row] for row in rows]
    t = Table(data, colWidths=widths, repeatRows=1, hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), NAVY), ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, MIST]),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE), ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5), ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 4.5), ("BOTTOMPADDING", (0, 0), (-1, -1), 4.5),
    ]))
    return t


def screenshot(path, height, caption):
    width = 166 * mm
    img = Image(str(path), width=width, height=height)
    t = Table([[img], [P(caption, "Small2")]], colWidths=[168 * mm], hAlign="CENTER")
    t.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, 0), 0.6, LINE), ("BACKGROUND", (0, 1), (-1, 1), MIST),
        ("LEFTPADDING", (0, 0), (-1, 0), 1 * mm), ("RIGHTPADDING", (0, 0), (-1, 0), 1 * mm),
        ("TOPPADDING", (0, 0), (-1, 0), 1 * mm), ("BOTTOMPADDING", (0, 0), (-1, 0), 1 * mm),
        ("LEFTPADDING", (0, 1), (-1, 1), 4 * mm), ("RIGHTPADDING", (0, 1), (-1, 1), 4 * mm),
        ("TOPPADDING", (0, 1), (-1, 1), 2 * mm), ("BOTTOMPADDING", (0, 1), (-1, 1), 2 * mm),
    ]))
    return t


def number_cards(items):
    cells = []
    for number, title, body in items:
        cells.append(Table([
            [P(str(number), "Eyebrow")], [P(title, "CardTitle")], [P(body, "Small2")]
        ], colWidths=[50 * mm], style=TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), MIST), ("BOX", (0, 0), (-1, -1), 0.5, LINE),
            ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ])))
    rows = [cells[i:i+3] for i in range(0, len(cells), 3)]
    return Table(rows, colWidths=[55 * mm] * 3, hAlign="LEFT", style=TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 0), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))


class StatTiles(Flowable):
    def __init__(self, values):
        super().__init__(); self.values = values; self.height = 31 * mm
    def wrap(self, aw, ah): self.width = aw; return aw, self.height
    def draw(self):
        c, w = self.canv, self.width
        gap = 4 * mm; tile = (w - gap * (len(self.values) - 1)) / len(self.values)
        for i, (label, value) in enumerate(self.values):
            x = i * (tile + gap)
            c.setFillColor(PALE); c.setStrokeColor(TEAL); c.roundRect(x, 0, tile, self.height, 3 * mm, fill=1, stroke=1)
            c.setFont(BOLD, 17); c.setFillColor(NAVY); c.drawCentredString(x + tile/2, 15 * mm, value)
            c.setFont(REG, 7); c.setFillColor(MUTED); c.drawCentredString(x + tile/2, 6 * mm, label.upper())


with open(ASSETS / "stats_summary.csv", newline="", encoding="utf-8") as f:
    stats = {row["metric"]: row["value"] for row in csv.DictReader(f)}
with open(ASSETS / "chi_square_summary.csv", newline="", encoding="utf-8") as f:
    chi = {row["metric"]: row["value"] for row in csv.DictReader(f)}
with open(ASSETS / "chi_square_cells.csv", newline="", encoding="utf-8") as f:
    chi_cells = list(csv.DictReader(f))


def chi_cell(period, rating, field):
    row = next(r for r in chi_cells if r["release_period"] == period and r["rating_category"] == rating)
    value = float(row[field])
    return str(int(value)) if field == "observed" else f"{value:.2f}"


story = []

# Page 1 - cover
story += [Spacer(1, 45 * mm), P("COMP3020", "Eyebrow"),
          P("TMDB API Setup and<br/>Statistical Analysis in R", "CoverTitle2"),
          P("A visual guide to creating developer access, installing tmdbR, collecting a bounded movie dataset, and describing it responsibly in RStudio.", "CoverDeck2"),
          Spacer(1, 17 * mm),
          Table([[P("REGISTER", "TableH2"), P("CONNECT", "TableH2"), P("DESCRIBE", "TableH2"), P("INTERPRET", "TableH2")],
                 [P("TMDB account + API", "Body2"), P("tmdbR 0.2.0", "Body2"), P("plots + summaries", "Body2"), P("limits + bias", "Body2")]],
                colWidths=[42 * mm] * 4, style=TableStyle([
                    ("BACKGROUND", (0, 0), (-1, 0), TEAL), ("BACKGROUND", (0, 1), (-1, 1), WHITE),
                    ("GRID", (0, 0), (-1, -1), 0.4, SKY), ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 7), ("TOPPADDING", (0, 0), (-1, -1), 7),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
                ])), Spacer(1, 12 * mm),
          P("Never place a real API token in code, screenshots, reports, or Git.", "CoverDeck2"), PageBreak()]

# Page 2 - roadmap
story += heading("Start here", "Your 45-minute setup path", "Complete the first seven steps once. The statistics workflow can then be reused for other questions and assignments.")
story += [number_cards([
    (1, "Create account", "Join TMDB on a desktop browser and verify your email."),
    (2, "Request API", "Settings > API > Request an API Key > Developer."),
    (3, "Describe use", "Enter honest educational, non-commercial application details."),
    (4, "Copy token", "Use the long API Read Access Token, not a session token."),
    (5, "Install R tools", "Install R, RStudio, and the supplied tmdbR archive."),
    (6, "Cache token", "Run tmdb_auth() once; the credential stays outside scripts."),
    (7, "Test access", "Request one known movie and check the returned title."),
    (8, "Ask a question", "Define a population, variables, and a bounded dataset."),
    (9, "Describe carefully", "Summarise, visualise, and state important limitations."),
]), Spacer(1, 3 * mm), P("Before you begin", "H2v2")]
story += bullets([
    "Use a desktop browser; TMDB's API registration flow is not designed for mobile.",
    "Install <link href='https://cran.r-project.org/' color='#0B6E99'>R 4.1.0 or later</link> and the current stable <link href='https://docs.posit.co/ide/user/' color='#0B6E99'>RStudio Desktop</link>.",
    "Keep the supplied <font name='GuideMono'>tmdbR_0.2.0.tar.gz</font> file zipped.",
    "Use truthful account and application information; you will accept TMDB's terms.",
])
story += [callout("Possible extension", "If an assignment permits an open-ended approach, explore TMDB fields, define a question, and choose methods that match the variables, assumptions, and research aim. The chi-square example is one possibility."), PageBreak()]

# Page 3 - account
story += heading("01 / TMDB account", "Join and verify your account", "Account creation is free. Use your own email address and keep the password private.")
story += [screenshot(ASSETS / "join_tmdb.png", 81 * mm,
                    "Real walkthrough screenshot: select Join TMDB in the top-right corner. Source: TMDB Quickstart mirror (accessed 8 August 2026)."),
          Spacer(1, 5 * mm), number_cards([
              (1, "Open sign-up", "Go to themoviedb.org/signup or select Join TMDB."),
              (2, "Enter details", "Create a username and strong, unique password."),
              (3, "Verify email", "Open TMDB's message and activate your account."),
          ]), P("Then sign in", "H2v2")]
story += bullets([
    "If the verification message is missing, check junk mail and confirm that your email was typed correctly.",
    "Return to TMDB and sign in. Your profile icon will appear in the top-right corner.",
    "Do not use disposable contact details: the API application asks for genuine information.",
])
story += [callout("Direct link", "<link href='https://www.themoviedb.org/signup' color='#0B6E99'>https://www.themoviedb.org/signup</link>", "teal"), PageBreak()]

# Page 4 - developer request
story += heading("02 / API access", "Open API settings and request a key", "The API menu is inside Account Settings. If you have never applied before, the page shows a Request an API Key section.")
story += [screenshot(ASSETS / "api_sidebar.png", 72 * mm,
                    "Select API in the Settings sidebar. Screenshot source: TMDB Quickstart mirror; example account details belong to the source author."),
          Spacer(1, 4 * mm), screenshot(ASSETS / "request_key.png", 72 * mm,
                    "Under Request an API Key, select the 'click here' link. The interface may move, but the wording remains the key landmark."),
          Spacer(1, 4 * mm), callout("Choose Developer", "Select the <b>Developer</b> application type for coursework and personal experiments. Read and accept TMDB's terms yourself; do not select Professional unless the intended use is genuinely commercial.", "orange"),
          P("Signed-in shortcut: <link href='https://www.themoviedb.org/settings/api' color='#0B6E99'>themoviedb.org/settings/api</link>", "Small2"), PageBreak()]

# Page 5 - form and token
story += heading("03 / Application details", "Describe the course project honestly", "The current Details page uses three application fields. Contact fields may also appear during first registration.")
story += [callout("Working example", "These values are copied from the instructor's accepted TMDB application Details page. Enter them exactly as shown for the COMP3020 course setup."),
Spacer(1, 4 * mm),
table(["Field", "Working COMP3020 value", "Purpose"], [
    ["Application Name", "<font name='GuideMono'>COMP3020</font>", "Identifies the course application."],
    ["Application URL", "<font name='GuideMono'>http:/127.0.0.1</font>", "Local course application address accepted in the working setup."],
    ["Application Summary", "<font name='GuideMono'>Test app for Western Sydney University COMP3020 Unit.</font>", "States the educational purpose concisely."],
], [38 * mm, 70 * mm, 58 * mm]), Spacer(1, 6 * mm),
screenshot(ASSETS / "read_access.png", 81 * mm,
           "After approval, return to Settings > API. Copy the long API Read Access Token. The source screenshot intentionally blurs both credentials."),
Spacer(1, 4 * mm),
table(["Use this", "Not this"], [
    ["<b>API Read Access Token</b><br/>Long bearer token used by tmdb_auth().", "Request token or session ID<br/>Used for user-approved write operations; tmdbR is read-only."],
    ["API Key (v3 auth)<br/>Supported alternative through TMDB_API_KEY.", "A token copied into an R script, report, screenshot, or Git repository."],
], [83 * mm, 83 * mm]),
callout("Credential rule", "Never show the token to another person. If it is exposed, regenerate it in TMDB settings and replace the cached value.", "orange"), PageBreak()]

# Page 6 - install
story += heading("04 / RStudio", "Install tmdbR in three clear steps", "Use the supplied release archive exactly as downloaded. RStudio will install it into your personal R package library.")
story += [callout("File you need", "<font name='GuideMono'>tmdbR_0.2.0.tar.gz</font> - keep it zipped and save it somewhere easy to find, such as Downloads or the course folder."),
P("Step 1 - Open the RStudio Console", "H2v2")]
story += bullets([
    "Start RStudio and wait until the blue <font name='GuideMono'>&gt;</font> prompt appears in the Console pane.",
    "Do not open, extract, or double-click the archive. The installation command reads it directly.",
])
story += [P("Step 2 - Choose and install the archive", "H2v2"),
code('package_file <- file.choose()\ninstall.packages(package_file, repos = NULL, type = "source")'),
callout("What happens", "A file chooser opens after the first line. Select <font name='GuideMono'>tmdbR_0.2.0.tar.gz</font> and choose Open. Then run the second line. Wait until the Console returns to the <font name='GuideMono'>&gt;</font> prompt."),
P("Step 3 - Load the package and verify the version", "H2v2"),
code('library(tmdbR)\npackageVersion("tmdbR")\n# Expected output: [1] \'0.2.0\''),
table(["If you see...", "Meaning / action"], [
    ["<font name='GuideMono'>[1] '0.2.0'</font>", "Installation succeeded. Continue to authentication on the next page."],
    ["Package is not available", "Check that you selected the supplied archive, not a folder or an unzipped file."],
    ["Compilation tools are missing", "Windows: install matching Rtools. macOS: install Apple's Command Line Tools. Restart RStudio and retry."],
], [55 * mm, 111 * mm]),
callout("Remember", "Install once per R library. In every new R session, load the installed package with <font name='GuideMono'>library(tmdbR)</font>."), PageBreak()]

# Page 7 - auth
story += heading("05 / Authentication", "Cache the bearer token once", "tmdb_auth() stores an encrypted token file in your user cache, outside the project and assignment scripts.")
story += [code('library(tmdbR)\ntmdb_auth()\n# Paste the long API Read Access Token only at the prompt'),
number_cards([
    (1, "Prompt appears", "Paste the long token, then press Enter."),
    (2, "Cache is written", "The file is outside the course project."),
    (3, "Future requests", "tmdbR finds the cached token automatically."),
]), P("Test with one known movie", "H2v2"),
code('test <- movie(id = 550, language = "en-AU")\ntest$title\n# Expected: "Fight Club"'),
table(["Task", "Command", "Safe result"], [
    ["Locate cache", "<font name='GuideMono'>tmdb_token_path()</font>", "Shows only the file path."],
    ["Replace token", "<font name='GuideMono'>tmdb_auth(overwrite = TRUE)</font>", "Prompts for a replacement."],
    ["Remove token", "<font name='GuideMono'>tmdb_forget_token()</font>", "Deletes the cached credential."],
], [36 * mm, 62 * mm, 68 * mm]),
callout("401 error?", "Copy the API Read Access Token again, check for leading/trailing spaces, and run <font name='GuideMono'>tmdb_auth(overwrite = TRUE)</font>. Never paste the token into a screenshot sent for help.", "orange"), PageBreak()]

# Page 8 - search and details
story += heading("06 / Finding records", "Search first, then request details by ID", "Names and titles are not unique. TMDB IDs are the reliable link between searches, movie details, people, and credits.")
story += [P("1. Search and inspect candidate rows", "CardTitle"),
compact_code('# Search by title, then display three rows as a checkpoint\nhits <- search_movie(query = "Spirited Away", language = "en-AU")\nhead(hits$results[c("id", "title", "release_date",\n                    "vote_average", "vote_count")], 3)'),
table(["ID", "Title", "Release date", "Rating", "Votes"], [
    ["129", "Spirited Away", "2001-07-20", "8.534", "18,651"],
    ["1450777", "Uncovering Spirited Away", "2024-07-07", "7.000", "1"],
    ["698296", "The Art of 'Spirited Away'", "2003-04-15", "8.167", "6"],
], [20 * mm, 62 * mm, 30 * mm, 25 * mm, 29 * mm]),
P("2. Select the correct ID and request related records", "CardTitle"),
compact_code('# Select the exact title and reuse its stable TMDB ID\nchosen <- subset(hits$results, title == "Spirited Away")\nmovie_id <- chosen$id[[1]]\ndetails <- movie(id = movie_id, language = "en-AU")\ncredits <- movie_credits(id = movie_id)\n# Display the fields used as output checks\ndetails[c("title", "runtime", "budget", "revenue") ]\nhead(credits$cast[c("name", "character")], 3)'),
Table([[
    table(["Details field", "Sample value"], [
        ["title", "Spirited Away"], ["runtime", "125 minutes"],
        ["budget", "19,000,000"], ["revenue", "274,925,095"],
    ], [28 * mm, 52 * mm]),
    table(["Cast name", "Character"], [
        ["Rumi Hiiragi", "Chihiro (voice)"],
        ["Miyu Irino", "Haku (voice)"],
        ["Mari Natsuki", "Yubaba / Zeniba (voice)"],
    ], [34 * mm, 46 * mm]),
]], colWidths=[83 * mm, 83 * mm], hAlign="LEFT", style=TableStyle([
    ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 3),
    ("TOPPADDING", (0, 0), (-1, -1), 0), ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
])),
P("Expected variation: the movie ID and title should match; ratings, vote counts, revenue, and result ordering can change as TMDB updates its data.", "Small2"), PageBreak()]

# Page 9 - chi-square question and data
story += heading("07 / Worked statistics example", "A six-step chi-square workflow", "Use one question, one contingency table, and one test. The same six-step structure can be reused for other pairs of categorical variables.")
story += [number_cards([
    (1, "Ask", "Write the research question."),
    (2, "Hypothesise", "State H0 and HA before testing."),
    (3, "Count", "Build the 3 x 2 table."),
    (4, "Check", "Inspect independence and expected counts."),
    (5, "Test", "Run chisq.test()."),
    (6, "Conclude", "Use p and context to answer."),
]),
callout("1. Research question", "Among currently popular Australian-market movies with at least 50 votes, is the proportion rated 7.5 or higher associated with release era?"),
P("2. State the hypotheses", "H2v2"),
table(["Hypothesis", "Statement"], [
    ["H<sub>0</sub>", "The distribution of rating category is independent of release era in the population represented by this sampling process."],
    ["H<sub>A</sub>", "The distribution of rating category differs across at least one release era."],
], [26 * mm, 140 * mm]),
P("Prepare the data with the R 4.1 pipe", "H2v2"),
compact_code('# Download a bounded set of popular Australian-market movies\nresponse <- movie_popular(\n  region = "AU", language = "en-AU", paginate = TRUE,\n  max_pages = 5, max_results = 100, deduplicate_by = "id"\n)\n\n# Begin with the movie rows stored in the API response\nmovies <- response$results |>\n  # Add a new variable to the data frame\n  transform(\n    # Extract the four-digit year from the release-date text\n    release_year = as.integer(substr(release_date, 1, 4))\n  ) |>\n  # Retain movies with 50+ votes and a known release year\n  subset(vote_count >= 50 & !is.na(release_year)) |>\n  # Add the two categorical variables required by the test\n  transform(\n    # Divide release year into three mutually exclusive eras\n    release_period = cut(\n      # -Inf and Inf include every possible year at the ends\n      release_year, c(-Inf, 2009, 2019, Inf),\n      # Apply readable labels in the same order as the intervals\n      labels = c("Before 2010", "2010-2019", "2020 or later")\n    ),\n    # Convert the numerical rating into two categories\n    rating_category = ifelse(\n      # TRUE receives the first label; FALSE receives the second\n      vote_average >= 7.5, "7.5 or higher", "Below 7.5"\n    )\n  )\n\n# Checkpoint: sort high to low, select columns, inspect three rows\npreview <- movies[order(movies$vote_average, decreasing = TRUE),\n  c("title", "release_year", "vote_average",\n    "release_period", "rating_category")]\nhead(preview, 3)'),
PageBreak()]

# Page 10 - table and conditions
story += heading("08 / Steps 3 and 4", "Count first, then check conditions", f"After applying the 50-vote rule, {chi['Movies analysed']} movies remained in the worked example.")
story += [P("Checkpoint: inspect the two analysis variables", "H2v2"),
table(["Movie", "Year", "Rating", "Release period", "Rating category"], [
    ["Avatar Aang: The Last Airbender", "2026", "9.300", "2020 or later", "7.5 or higher"],
    ["Swapped", "2026", "8.888", "2020 or later", "7.5 or higher"],
    ["The Shawshank Redemption", "1995", "8.727", "Before 2010", "7.5 or higher"],
], [54 * mm, 17 * mm, 19 * mm, 36 * mm, 40 * mm]),
P("3. Build the observed-count table", "H2v2"),
table(["Release era", "Rated 7.5 or higher", "Rated below 7.5", "Row total"], [
    ["Before 2010", chi_cell("Before 2010", "7.5 or higher", "observed"), chi_cell("Before 2010", "Below 7.5", "observed"), "11"],
    ["2010-2019", chi_cell("2010-2019", "7.5 or higher", "observed"), chi_cell("2010-2019", "Below 7.5", "observed"), "12"],
    ["2020 or later", chi_cell("2020 or later", "7.5 or higher", "observed"), chi_cell("2020 or later", "Below 7.5", "observed"), "56"],
    ["Column total", "41", "38", chi["Movies analysed"]],
], [52 * mm, 42 * mm, 40 * mm, 32 * mm]), Spacer(1, 7 * mm),
Image(str(ASSETS / "chi_square_bars.png"), width=166 * mm, height=60 * mm),
P("Compare the proportions within each release-era group before reading the test result.", "Small2"),
P("4. Check expected counts if H0 is true", "H2v2"),
table(["Release era", "Rated 7.5 or higher", "Rated below 7.5"], [
    ["Before 2010", chi_cell("Before 2010", "7.5 or higher", "expected"), chi_cell("Before 2010", "Below 7.5", "expected")],
    ["2010-2019", chi_cell("2010-2019", "7.5 or higher", "expected"), chi_cell("2010-2019", "Below 7.5", "expected")],
    ["2020 or later", chi_cell("2020 or later", "7.5 or higher", "expected"), chi_cell("2020 or later", "Below 7.5", "expected")],
], [62 * mm, 52 * mm, 52 * mm]),
table(["Condition", "Check"], [
    ["Count data", "Each movie contributes to exactly one cell."],
    ["Independent observations", "No duplicate movie IDs were retained."],
    ["Expected counts", f"Smallest expected count = {chi['Minimum expected count']}; all six are at least 5."],
], [47 * mm, 119 * mm]),
PageBreak()]

# Page 11 - test and interpretation
story += heading("09 / Steps 5 and 6", "Test, decide, and answer the question", "chisq.test() performs Pearson's chi-square test on this 3 x 2 contingency table.")
story += [P("5. Run the test and check its output", "H2v2"),
code('# Step 3: create and display the observed-count table\ncounts <- with(movies, table(release_period, rating_category))\ncounts\n# Step 4: test, then check that expected counts are at least 5\nfit <- chisq.test(counts)\nround(fit$expected, 2)\n# Step 5: keep the three statistics needed for reporting\nfit[c("statistic", "parameter", "p.value")]\n# Step 6: compare p with the chosen significance level\nalpha <- 0.05\nif (fit$p.value < alpha) "Reject H0" else "Fail to reject H0"'),
StatTiles([("Movies", chi["Movies analysed"]), ("Chi-square", chi["Chi-square"]),
           ("df", chi["Degrees of freedom"]), ("p-value", chi["p-value"])]), Spacer(1, 7 * mm),
table(["6. Conclude", "Interpretation"], [
    ["Compare", f"p = {chi['p-value']} is greater than alpha = 0.05."],
    ["Decision", "Fail to reject H<sub>0</sub>; the result is not statistically significant at the 5% level."],
    ["Answer", "This sample does not provide sufficient evidence that rating category differs across the three release eras."],
], [34 * mm, 132 * mm]),
callout("Model report", f"A chi-square test of independence found insufficient evidence of an association between release era and rating category, X<super>2</super>({chi['Degrees of freedom']}, N = {chi['Movies analysed']}) = {chi['Chi-square']}, p = {chi['p-value']}."),
P("What this result does not mean", "H2v2")]
story += bullets([
    "It does not prove that the variables are independent; it only says this sample did not provide sufficient evidence at alpha = 0.05.",
    "It does not show causation. Release era cannot be said to cause a movie to cross the rating threshold.",
    "Changing thresholds after seeing the data would change the question and may inflate false-positive risk.",
    "TMDB's popular list changes over time, so record the retrieval date and expect counts to differ on another day.",
])
story += [callout("Extension", "For a formal assignment, justify the categories before analysis and discuss whether the popularity-ranked sample represents the population named in your research question.", "orange"), PageBreak()]

# Page 12 - package help and student-focused function directory
story += heading("Keep nearby", "Package help and function categories", "Use R's help system to inspect arguments and examples. The directory below highlights the functions students are most likely to need.")
story += [P("Open help from the RStudio Console", "H2v2"),
compact_code('# Open the package index and browse all documented topics\nhelp(package = "tmdbR")\n# Open one function help page\n?search_movie\n# Display its formal arguments\nargs(search_movie)\n# Search package help for a word or phrase\nhelp.search("credits", package = "tmdbR")\n# List functions after library(tmdbR) has been run\nls("package:tmdbR")'),
P("Common functions by category", "H2v2"),
table(["Category", "Useful functions"], [
    ["Authentication and settings", fn_list(["tmdb_config", "tmdb_credentials", "tmdb_auth", "tmdb_token_path", "tmdb_forget_token"])],
    ["Requests and pagination", fn_list(["tmdb_request", "tmdb_request_all", "tmdb_paginate"])],
    ["Search", fn_list(["search_movie", "search_person", "search_multi", "search_keyword", "search_tv"])],
    ["Movies", fn_list(["movie", "movie_credits", "movie_keywords", "movie_reviews", "movie_similar", "movie_popular", "movie_top_rated", "movie_now_playing"])],
    ["Television", fn_list(["tv", "tv_credits", "tv_episode", "tv_season", "tv_popular", "tv_top_rated"])],
    ["People", fn_list(["person_tmdb", "person_movie_credits", "person_combined_credits", "person_popular"])],
    ["Discovery and reference", fn_list(["discover_movie", "discover_tv", "genres_movie_list", "genres_tv_list", "configuration", "find_tmdb"])],
], [42 * mm, 124 * mm]), PageBreak()]

# Page 13 - troubleshooting and sources
story += heading("Keep nearby", "Troubleshooting and sources", "Check installation, authentication, request limits, and response structure before changing an analysis.")
story += [P("Fast troubleshooting", "H2v2"),
table(["Symptom", "Action"], [
    ["Package will not install", "Check archive path and platform build tools; restart RStudio."],
    ["Missing credentials / 401", "Run tmdb_auth(); replace the cache if the token was copied incorrectly."],
    ["HTTP 429", "Wait and reduce pages. Keep sequential requests and bounded limits."],
    ["Empty results", "Relax filters, verify IDs, and inspect the first response page."],
    ["Nested or irregular fields", "Use names(), str(), or simplify = FALSE before analysis."],
], [49 * mm, 117 * mm]), Spacer(1, 5 * mm),
callout("Before submission", "Remove credentials; record retrieval date, endpoint, filters, rows, and truncation; label plots; distinguish description from causal explanation; attribute TMDB."),
P("Sources and further help", "H2v2"),
P('Official: <link href="https://developer.themoviedb.org/docs/authentication-application" color="#0B6E99">TMDB application authentication</link>; <link href="https://developer.themoviedb.org/docs/faq" color="#0B6E99">TMDB FAQ and attribution</link>; <link href="https://www.themoviedb.org/settings/api" color="#0B6E99">signed-in API settings</link>. Visual walkthrough screenshots: <link href="https://ileolami.mintlify.app/the-basics/quickstart" color="#0B6E99">TMDB Quickstart mirror</link>, accessed 8 August 2026. Package help: <font name="GuideMono">help(package = "tmdbR")</font>. Advanced exercise: <font name="GuideMono">scripts/mcu_actor_network.R</font>.', "Small2")]


def build():
    missing = [p for p in [
        ASSETS / "join_tmdb.png", ASSETS / "api_sidebar.png", ASSETS / "request_key.png",
        ASSETS / "read_access.png", ASSETS / "rating_histogram.png",
        ASSETS / "rating_votes_scatter.png", ASSETS / "stats_summary.csv",
        ASSETS / "chi_square_bars.png", ASSETS / "chi_square_summary.csv",
        ASSETS / "chi_square_cells.csv",
        ROOT / "tmp" / "pdfs" / "student_guide" / "assets" / "rstudio_console.png",
    ] if not p.exists()]
    if missing:
        raise FileNotFoundError(f"Missing guide assets: {missing}")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    GuideDoc(str(OUT)).build(story)
    print(OUT)


if __name__ == "__main__":
    build()
