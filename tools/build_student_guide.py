from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfgen import canvas
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame, Paragraph, Spacer, Table, TableStyle,
    PageBreak, KeepTogether, Flowable, HRFlowable, Image
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf" / "tmdbR_student_guide.pdf"
ASSETS = ROOT / "tmp" / "pdfs" / "student_guide" / "assets"

NAVY = HexColor("#071D2B")
BLUE = HexColor("#0B6E99")
CYAN = HexColor("#24C6DC")
PALE = HexColor("#EAF7FA")
INK = HexColor("#17252D")
MUTED = HexColor("#59717D")
LIGHT = HexColor("#F4F7F8")
LINE = HexColor("#CAD9DE")
GREEN = HexColor("#218A68")
AMBER = HexColor("#A76500")
RED = HexColor("#B33A3A")
WHITE = colors.white


def register_fonts():
    candidates = [
        ("Inter", "/System/Library/Fonts/Supplemental/Arial.ttf"),
        ("Inter-Bold", "/System/Library/Fonts/Supplemental/Arial Bold.ttf"),
        ("Mono", "/System/Library/Fonts/SFNSMono.ttf"),
    ]
    for name, path in candidates:
        if Path(path).exists():
            pdfmetrics.registerFont(TTFont(name, path))
    return (
        "Inter" if "Inter" in pdfmetrics.getRegisteredFontNames() else "Helvetica",
        "Inter-Bold" if "Inter-Bold" in pdfmetrics.getRegisteredFontNames() else "Helvetica-Bold",
        "Mono" if "Mono" in pdfmetrics.getRegisteredFontNames() else "Courier",
    )


BODY_FONT, BOLD_FONT, MONO_FONT = register_fonts()


class MockWindow(Flowable):
    def __init__(self, title, rows, height=92 * mm, accent=CYAN):
        super().__init__()
        self.title, self.rows, self.height, self.accent = title, rows, height, accent
        self.width = 170 * mm

    def wrap(self, availWidth, availHeight):
        self.width = min(self.width, availWidth)
        return self.width, self.height

    def draw(self):
        c, w, h = self.canv, self.width, self.height
        c.setStrokeColor(LINE); c.setFillColor(WHITE)
        c.roundRect(0, 0, w, h, 4 * mm, fill=1, stroke=1)
        c.setFillColor(NAVY); c.roundRect(0, h - 13 * mm, w, 13 * mm, 4 * mm, fill=1, stroke=0)
        c.rect(0, h - 13 * mm, w, 6 * mm, fill=1, stroke=0)
        c.setFont(BOLD_FONT, 10); c.setFillColor(WHITE); c.drawString(8 * mm, h - 8.5 * mm, self.title)
        c.setFillColor(HexColor("#FF6B6B")); c.circle(w - 18 * mm, h - 6.5 * mm, 1.6 * mm, fill=1, stroke=0)
        c.setFillColor(HexColor("#FFD166")); c.circle(w - 12 * mm, h - 6.5 * mm, 1.6 * mm, fill=1, stroke=0)
        c.setFillColor(HexColor("#65D69E")); c.circle(w - 6 * mm, h - 6.5 * mm, 1.6 * mm, fill=1, stroke=0)
        y = h - 24 * mm
        for label, text, kind in self.rows:
            if kind == "sidebar":
                c.setFillColor(LIGHT); c.roundRect(5 * mm, y - 7 * mm, 42 * mm, 10 * mm, 2 * mm, fill=1, stroke=0)
                c.setFillColor(self.accent); c.rect(5 * mm, y - 7 * mm, 2 * mm, 10 * mm, fill=1, stroke=0)
                c.setFont(BOLD_FONT, 8.5); c.setFillColor(INK); c.drawString(10 * mm, y - 1 * mm, label)
                c.setFont(BODY_FONT, 7.5); c.setFillColor(MUTED); c.drawString(52 * mm, y, text)
                y -= 14 * mm
            elif kind == "secret":
                c.setFont(BOLD_FONT, 8.5); c.setFillColor(INK); c.drawString(8 * mm, y, label)
                c.setFillColor(LIGHT); c.roundRect(8 * mm, y - 10 * mm, w - 28 * mm, 8 * mm, 1.5 * mm, fill=1, stroke=0)
                c.setFont(MONO_FONT, 7.5); c.setFillColor(MUTED); c.drawString(12 * mm, y - 7 * mm, text)
                c.setFillColor(self.accent); c.roundRect(w - 17 * mm, y - 10 * mm, 10 * mm, 8 * mm, 1.5 * mm, fill=1, stroke=0)
                c.setFont(BOLD_FONT, 7); c.setFillColor(NAVY); c.drawCentredString(w - 12 * mm, y - 7 * mm, "COPY")
                y -= 18 * mm
            else:
                c.setFillColor(self.accent); c.circle(11 * mm, y, 3 * mm, fill=1, stroke=0)
                c.setFont(BOLD_FONT, 8); c.setFillColor(NAVY); c.drawCentredString(11 * mm, y - 2.5, label)
                c.setFont(BODY_FONT, 8.3); c.setFillColor(INK); c.drawString(18 * mm, y - 2.5, text)
                y -= 12 * mm


class ProgressPath(Flowable):
    def __init__(self, labels, light=False):
        super().__init__(); self.labels = labels; self.light = light; self.height = 25 * mm

    def wrap(self, availWidth, availHeight): self.width = availWidth; return availWidth, self.height

    def draw(self):
        c, w = self.canv, self.width
        xs = [13 * mm + i * (w - 26 * mm) / (len(self.labels) - 1) for i in range(len(self.labels))]
        c.setStrokeColor(CYAN); c.setLineWidth(2); c.line(xs[0], 15 * mm, xs[-1], 15 * mm)
        for i, (x, label) in enumerate(zip(xs, self.labels), 1):
            c.setFillColor(NAVY); c.circle(x, 15 * mm, 4.3 * mm, fill=1, stroke=0)
            c.setFont(BOLD_FONT, 8); c.setFillColor(WHITE); c.drawCentredString(x, 12.2 * mm, str(i))
            c.setFont(BODY_FONT, 7.2); c.setFillColor(WHITE if self.light else INK); c.drawCentredString(x, 4 * mm, label)


class GuideDoc(BaseDocTemplate):
    def __init__(self, filename):
        super().__init__(filename, pagesize=A4, leftMargin=19 * mm, rightMargin=19 * mm,
                         topMargin=22 * mm, bottomMargin=18 * mm,
                         title="tmdbR 0.2.0 Student Guide", author="COMP3020")
        frame = Frame(self.leftMargin, self.bottomMargin, self.width, self.height, id="main")
        self.addPageTemplates(PageTemplate(id="guide", frames=[frame], onPage=self.decorate))

    def decorate(self, c: canvas.Canvas, doc):
        p = c.getPageNumber()
        c.saveState()
        if p == 1:
            c.setFillColor(NAVY); c.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
            c.setFillColor(BLUE); c.circle(A4[0] - 24 * mm, A4[1] - 30 * mm, 34 * mm, fill=1, stroke=0)
            c.setFillColor(CYAN); c.circle(A4[0] - 9 * mm, A4[1] - 13 * mm, 18 * mm, fill=1, stroke=0)
        else:
            c.setFillColor(NAVY); c.rect(0, A4[1] - 10 * mm, A4[0], 10 * mm, fill=1, stroke=0)
            c.setFont(BOLD_FONT, 8); c.setFillColor(WHITE)
            c.drawString(19 * mm, A4[1] - 6.6 * mm, "COMP3020  |  tmdbR STUDENT GUIDE")
            c.setStrokeColor(LINE); c.line(19 * mm, 13 * mm, A4[0] - 19 * mm, 13 * mm)
            c.setFont(BODY_FONT, 7.5); c.setFillColor(MUTED)
            c.drawString(19 * mm, 8.5 * mm, "tmdbR 0.2.0  |  Updated 8 August 2026")
            c.drawRightString(A4[0] - 19 * mm, 8.5 * mm, f"{p} / 9")
        c.restoreState()


styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="CoverKicker", fontName=BOLD_FONT, fontSize=11, leading=14,
                          textColor=CYAN, spaceAfter=8, tracking=1.4))
styles.add(ParagraphStyle(name="CoverTitle", fontName=BOLD_FONT, fontSize=31, leading=34,
                          textColor=WHITE, spaceAfter=12))
styles.add(ParagraphStyle(name="CoverSub", fontName=BODY_FONT, fontSize=13, leading=19,
                          textColor=HexColor("#D9EEF2"), spaceAfter=12))
styles.add(ParagraphStyle(name="H1x", fontName=BOLD_FONT, fontSize=22, leading=26,
                          textColor=NAVY, spaceAfter=5))
styles.add(ParagraphStyle(name="Deck", fontName=BODY_FONT, fontSize=10.5, leading=15,
                          textColor=MUTED, spaceAfter=10))
styles.add(ParagraphStyle(name="H2x", fontName=BOLD_FONT, fontSize=13, leading=16,
                          textColor=BLUE, spaceBefore=7, spaceAfter=5))
styles.add(ParagraphStyle(name="Bodyx", fontName=BODY_FONT, fontSize=9.1, leading=13,
                          textColor=INK, spaceAfter=5))
styles.add(ParagraphStyle(name="Small", fontName=BODY_FONT, fontSize=7.7, leading=10.4,
                          textColor=MUTED))
styles.add(ParagraphStyle(name="Callout", fontName=BODY_FONT, fontSize=8.7, leading=12.3,
                          textColor=INK, backColor=PALE, borderColor=CYAN, borderWidth=0.7,
                          borderPadding=7, leftIndent=0, spaceBefore=4, spaceAfter=7))
styles.add(ParagraphStyle(name="Warn", parent=styles["Callout"], backColor=HexColor("#FFF4DD"),
                          borderColor=HexColor("#F0B44D")))
styles.add(ParagraphStyle(name="CodeX", fontName=MONO_FONT, fontSize=7.6, leading=10.2,
                          textColor=HexColor("#D8F3F8"), backColor=NAVY, borderPadding=8,
                          spaceBefore=3, spaceAfter=7))
styles.add(ParagraphStyle(name="TableHead", fontName=BOLD_FONT, fontSize=7.8, leading=9.5,
                          textColor=WHITE))
styles.add(ParagraphStyle(name="TableBody", fontName=BODY_FONT, fontSize=7.4, leading=9.5,
                          textColor=INK))


def P(text, style="Bodyx"): return Paragraph(text, styles[style])
def code(text): return Paragraph(text.replace(" ", "&nbsp;").replace("\n", "<br/>"), styles["CodeX"])
def title(num, heading, deck): return [P(f"{num:02d}  /  GUIDE", "CoverKicker"), P(heading, "H1x"), P(deck, "Deck")]
def bullets(items):
    return [P(f"<font color='#24A1B6'><b>•</b></font> {x}") for x in items]


def matrix(headers, rows, widths, font=7.4):
    data = [[P(x, "TableHead") for x in headers]] + [[P(x, "TableBody") for x in row] for row in rows]
    t = Table(data, colWidths=widths, repeatRows=1, hAlign="LEFT")
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), NAVY), ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("GRID", (0, 0), (-1, -1), 0.35, LINE), ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5), ("TOPPADDING", (0, 0), (-1, -1), 4.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4.5),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, LIGHT]),
    ]))
    return t


def screenshot(path, width, height, caption):
    img = Image(str(path), width=width, height=height)
    box = Table([[img], [P(caption, "Small")]], colWidths=[width + 4 * mm], hAlign="CENTER")
    box.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, 0), 0.6, LINE),
        ("BACKGROUND", (0, 1), (-1, 1), LIGHT),
        ("LEFTPADDING", (0, 0), (-1, 0), 2 * mm), ("RIGHTPADDING", (0, 0), (-1, 0), 2 * mm),
        ("TOPPADDING", (0, 0), (-1, 0), 2 * mm), ("BOTTOMPADDING", (0, 0), (-1, 0), 2 * mm),
        ("LEFTPADDING", (0, 1), (-1, 1), 4 * mm), ("RIGHTPADDING", (0, 1), (-1, 1), 4 * mm),
        ("TOPPADDING", (0, 1), (-1, 1), 2 * mm), ("BOTTOMPADDING", (0, 1), (-1, 1), 2 * mm),
    ]))
    return box


story = []

# 1 - cover
story += [Spacer(1, 46 * mm), P("COMP3020  |  STUDENT STARTER GUIDE", "CoverKicker"),
          P("Movie data in R<br/>with tmdbR", "CoverTitle"),
          P("Create your TMDB developer access, install the course package, authenticate safely, and build an analysis-ready dataset.", "CoverSub"),
          Spacer(1, 12 * mm), ProgressPath(["Register", "Install", "Connect", "Search", "Analyse"], light=True),
          Spacer(1, 14 * mm),
          Table([[P("PACKAGE", "TableHead"), P("PLATFORM", "TableHead"), P("GUIDE DATE", "TableHead")],
                 [P("tmdbR 0.2.0", "Bodyx"), P("RStudio - Windows & macOS", "Bodyx"), P("8 August 2026", "Bodyx")]],
                colWidths=[52 * mm, 69 * mm, 49 * mm], style=TableStyle([
                    ("BACKGROUND", (0, 0), (-1, 0), BLUE), ("BACKGROUND", (0, 1), (-1, 1), WHITE),
                    ("BOX", (0, 0), (-1, -1), 0.6, CYAN), ("INNERGRID", (0, 0), (-1, -1), 0.3, LINE),
                    ("VALIGN", (0, 0), (-1, -1), "MIDDLE"), ("LEFTPADDING", (0, 0), (-1, -1), 7),
                    ("TOPPADDING", (0, 0), (-1, -1), 7), ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
                ])),
          Spacer(1, 12 * mm), P("Keep your token private. Examples in this guide never contain a real credential.", "CoverSub"), PageBreak()]

# 2 - account
story += title(1, "Create your TMDB developer access", "The API is free for non-commercial educational use, subject to TMDB's terms and attribution requirements.")
story += [ProgressPath(["Create account", "Verify email", "Open Settings", "Choose API", "Apply"]),
          screenshot(ASSETS / "tmdb_signup.png", 148 * mm, 83.6 * mm,
                     "Real TMDB sign-up page captured 8 August 2026. Complete it yourself; never share your password."),
          Spacer(1, 3 * mm), P("After registration", "H2x")]
story += bullets(["Use your own verified TMDB account and truthful contact details.",
                  "Open your avatar menu, choose Settings, then select API in the left sidebar (or open <link href='https://www.themoviedb.org/settings/api' color='#0B6E99'>the signed-in API settings page</link>).",
                  "Describe the activity as coursework or statistical analysis using movie metadata.",
                  "Do not describe a commercial product if the work is only for this subject."])
story += [P("<b>Attribution:</b> if you publish an app or report using TMDB data or images, identify TMDB as the source and include: “This product uses the TMDB API but is not endorsed or certified by TMDB.”", "Callout"),
          P("Official references: <link href='https://developer.themoviedb.org/docs/faq' color='#0B6E99'>TMDB FAQ</link> and <link href='https://developer.themoviedb.org/docs/authentication-application' color='#0B6E99'>application authentication</link>.", "Small"), PageBreak()]

# 3 token
story += title(2, "Copy the correct token", "tmdbR is read-only. It needs application authentication, not a session that writes to a user's TMDB account.")
story += [screenshot(ASSETS / "tmdb_authentication.png", 158 * mm, 89.2 * mm,
                    "Official TMDB authentication guide. The highlighted Bearer Token section names the API Read Access Token."),
Spacer(1, 4 * mm),
matrix(["Credential", "Use with tmdbR", "Notes"], [
    ["API Read Access Token", "Recommended: <font name='Mono'>tmdb_auth()</font>", "Long bearer token shown in API settings."],
    ["API Key (v3 auth)", "Supported: <font name='Mono'>TMDB_API_KEY</font>", "Shorter alternative with the same read access."],
    ["Request/session token", "Do not use", "For user-approved write workflows; not needed here."],
], [43 * mm, 55 * mm, 72 * mm]), Spacer(1, 5 * mm),
P("<b>In Account Settings > API:</b> copy the long API Read Access Token into <font name='Mono'>tmdb_auth()</font>. Do not copy spaces or quotation marks. Treat both credentials like passwords and never commit, submit, print, or screen-share them.", "Warn"), PageBreak()]

# 4 install
story += title(3, "Install the course package", "Use the supplied release archive. You do not need to build the package from its source files.")
story += [P("Before you begin", "H2x")]
story += bullets(["Install <link href='https://cran.r-project.org/' color='#0B6E99'>R 4.1.0 or later</link>, then install the current stable <link href='https://docs.posit.co/ide/user/' color='#0B6E99'>RStudio Desktop</link> build for your operating system.",
                  "Save <font name='Mono'>tmdbR_0.2.0.tar.gz</font> in a known folder. Do not unzip it.",
                  "Source installation may require Rtools on Windows or Command Line Tools on macOS if no compatible build tools are already present."])
story += [P("Option A - RStudio console (recommended)", "H2x"),
code("pkg <- file.choose()\ninstall.packages(pkg, repos = NULL, type = \"source\")\nlibrary(tmdbR)\npackageVersion(\"tmdbR\")"),
P("<b>Expected:</b> package version <font name='Mono'>0.2.0</font>. Restart R and run the last two lines again if RStudio asks to update loaded packages.", "Callout"),
P("Option B - whole project helper", "H2x"),
code("# Set the working directory to the supplied project folder first\nsource(\"scripts/install_tmdbR.R\")"),
P("The helper also installs <font name='Mono'>igraph</font> for the separate MCU network exercise.", "Bodyx"),
screenshot(ASSETS / "rstudio_console.png", 158 * mm, 88.9 * mm,
           "Real RStudio console with the installed course package returning version 0.2.0."), PageBreak()]

# 5 auth
story += title(4, "Authenticate safely", "Cache the bearer token once outside your scripts, then let tmdbR reuse it automatically.")
story += [P("Recommended one-time setup", "H2x"),
code("library(tmdbR)\ntmdb_auth()\n# Paste the long API Read Access Token only at the prompt"),
MockWindow("RStudio Console - safe mockup", [
    ("1", "Paste your TMDB API Read Access Token: [hidden while sharing]", "step"),
    ("2", "TMDB token saved to your user cache", "step"),
    ("3", "The token is not stored in the project folder.", "step"),
], height=52 * mm, accent=HexColor("#74C69D")),
P("Test the connection", "H2x"),
code("test_movie <- movie(id = 550, language = \"en-AU\")\ntest_movie$title\n# Expected title: Fight Club"),
matrix(["Task", "Command", "What it does"], [
    ["Locate cache", "<font name='Mono'>tmdb_token_path()</font>", "Shows the path without revealing the token."],
    ["Replace token", "<font name='Mono'>tmdb_auth(overwrite = TRUE)</font>", "Prompts for a new token."],
    ["Remove token", "<font name='Mono'>tmdb_forget_token()</font>", "Deletes the cached credential."],
], [35 * mm, 58 * mm, 77 * mm]),
P("Session alternatives: <font name='Mono'>Sys.setenv(TMDB_BEARER_TOKEN = \"...\")</font> or <font name='Mono'>Sys.setenv(TMDB_API_KEY = \"...\")</font>. These vanish when R closes unless you deliberately configure them elsewhere. Never place a real value in submitted code.", "Warn"), PageBreak()]

# 6 workflow 1
story += title(5, "Search, select, and inspect", "TMDB search results are ordinary R data frames inside the response's results field.")
story += [P("1. Search for a movie", "H2x"),
code("hits <- search_movie(\n  query = \"Spirited Away\",\n  language = \"en-AU\", region = \"AU\"\n)\n\nhead(hits$results[c(\"id\", \"title\", \"release_date\",\n                    \"vote_average\", \"vote_count\")])"),
P("2. Choose an ID, then request details and credits", "H2x"),
code("movie_id <- hits$results$id[[1]]\nfilm <- movie(id = movie_id, language = \"en-AU\")\ncredits <- movie_credits(id = movie_id)\n\nfilm[c(\"title\", \"release_date\", \"runtime\", \"budget\",\n       \"revenue\", \"vote_average\", \"vote_count\")]\nhead(credits$cast[c(\"id\", \"name\", \"character\")])"),
P("Know the response shape", "H2x"),
matrix(["Expression", "Typical type", "Meaning"], [
    ["<font name='Mono'>hits</font>", "List", "Page metadata plus the results table."],
    ["<font name='Mono'>hits$results</font>", "Data frame", "One row per search result."],
    ["<font name='Mono'>film</font>", "List", "Fields and nested tables for one movie."],
    ["<font name='Mono'>credits$cast</font>", "Data frame", "One row per credited cast member."],
], [49 * mm, 36 * mm, 85 * mm]),
P("Use <font name='Mono'>str(object, max.level = 2)</font> and <font name='Mono'>names(object)</font> before analysing unfamiliar responses. TMDB fields may be absent or nested depending on the endpoint.", "Callout"), PageBreak()]

# 7 workflow 2
story += title(6, "Build an analysis-ready dataset", "Use explicit limits while developing. Expand only after checking the returned rows and variables.")
story += [P("Collect a bounded sample", "H2x"),
code("sample <- discover_movie(\n  language = \"en-AU\", region = \"AU\",\n  sort_by = \"vote_count.desc\", vote_count.gte = 100,\n  paginate = TRUE, max_pages = 3, max_results = 60,\n  deduplicate_by = \"id\", progress = TRUE\n)\nmovies <- sample$results"),
P("Clean and summarise with base R", "H2x"),
code("keep <- c(\"id\", \"title\", \"release_date\",\n          \"vote_average\", \"vote_count\", \"popularity\")\nmovies <- movies[keep]\nmovies$release_date <- as.Date(movies$release_date)\nmovies <- movies[!is.na(movies$vote_average) &\n                 !is.na(movies$vote_count), ]\nmovies$release_year <- as.integer(format(movies$release_date, \"%Y\"))\n\nsummary(movies[c(\"vote_average\", \"vote_count\", \"popularity\")])\nhead(movies[order(-movies$vote_average, -movies$vote_count), ], 10)\naggregate(vote_average ~ release_year, movies, mean)"),
matrix(["Check", "Why it matters"], [
    ["<font name='Mono'>nrow(movies)</font>", "Confirms your actual sample size."],
    ["<font name='Mono'>colSums(is.na(movies))</font>", "Finds missing values before summaries or models."],
    ["<font name='Mono'>sample$truncated</font>", "Reports whether a safety limit stopped collection."],
    ["<font name='Mono'>sample$pages_fetched</font>", "Records how many API pages were requested."],
], [66 * mm, 104 * mm]),
P("<b>Interpret carefully:</b> TMDB popularity, ratings, and vote counts change over time. Record the retrieval date and avoid treating user ratings as a representative population sample.", "Warn"), PageBreak()]

# 8 cheat sheet
story += title(7, "Function cheat sheet", "Start with a convenience function. Use the generic request functions only when no wrapper exists.")
story += [matrix(["Goal", "Useful functions", "Typical output / use"], [
    ["Search", "<font name='Mono'>search_movie()</font><br/><font name='Mono'>search_person()</font><br/><font name='Mono'>search_multi()</font><br/><font name='Mono'>search_keyword()</font>", "Find IDs from text. Read the <font name='Mono'>$results</font> table."],
    ["Movie details", "<font name='Mono'>movie()</font><br/><font name='Mono'>movie_credits()</font><br/><font name='Mono'>movie_reviews()</font><br/><font name='Mono'>movie_keywords()</font><br/><font name='Mono'>movie_similar()</font>", "Metadata, cast and crew, reviews, tags, and recommendations for a movie ID."],
    ["Discover datasets", "<font name='Mono'>discover_movie()</font><br/><font name='Mono'>movie_popular()</font><br/><font name='Mono'>movie_top_rated()</font><br/><font name='Mono'>movie_now_playing()</font>", "Filtered or ranked result pages. Most support safe opt-in pagination."],
    ["People", "<font name='Mono'>person_tmdb()</font><br/><font name='Mono'>person_movie_credits()</font><br/><font name='Mono'>person_combined_credits()</font>", "Person details and movie/TV credit tables."],
    ["Supporting metadata", "<font name='Mono'>genres_movie_list()</font><br/><font name='Mono'>configuration()</font>", "Genre ID lookup and TMDB image/configuration metadata."],
    ["More pages", "<font name='Mono'>paginate = TRUE</font><br/><font name='Mono'>tmdb_paginate()</font><br/><font name='Mono'>tmdb_request_all()</font>", "Combine sequential pages with page, result, and memory limits."],
    ["Any v3 endpoint", "<font name='Mono'>tmdb_request()</font>", "Direct request when the package has no convenience wrapper."],
], [34 * mm, 64 * mm, 72 * mm]), Spacer(1, 5 * mm),
P("Pagination pattern", "H2x"),
code("popular <- movie_popular(\n  region = \"AU\", paginate = TRUE,\n  max_pages = 5, max_results = 100,\n  deduplicate_by = \"id\", progress = TRUE\n)"),
P("Package help: <font name='Mono'>help(package = \"tmdbR\")</font>, <font name='Mono'>?tmdb_movies</font>, <font name='Mono'>?tmdb_people</font>, and <font name='Mono'>?tmdb_search</font>.", "Callout"), PageBreak()]

# 9 troubleshooting
story += title(8, "Troubleshoot and continue", "Read the complete error first. Most setup problems fall into one of these categories.")
story += [matrix(["Symptom", "Likely cause", "Action"], [
    ["Source package will not install", "Build tools or a dependency are missing.", "Install Rtools (Windows) or Command Line Tools (macOS); restart RStudio and retry."],
    ["Credentials are missing", "No cache or environment credential exists.", "Run <font name='Mono'>tmdb_auth()</font> and paste the long bearer token."],
    ["HTTP 401", "Wrong, incomplete, expired, or revoked credential.", "Copy the API Read Access Token again; use <font name='Mono'>tmdb_auth(overwrite = TRUE)</font>."],
    ["HTTP 429", "Too many requests in a short period.", "Wait, reduce pages, and keep sequential pagination. The package retries transient failures."],
    ["Empty results", "Search/filter is too narrow or wrong ID was used.", "Inspect the first search page, simplify filters, verify IDs, language, and region."],
    ["Result stopped early", "A page, row, or memory limit was reached.", "Check <font name='Mono'>$truncated</font>; increase one limit deliberately, not all at once."],
    ["Unexpected list/data frame", "The endpoint contains nested or heterogeneous fields.", "Use <font name='Mono'>str()</font>, <font name='Mono'>names()</font>, or <font name='Mono'>simplify = FALSE</font>."],
], [37 * mm, 56 * mm, 77 * mm]), Spacer(1, 6 * mm),
P("Next step: the MCU actor network", "H2x"),
P("The project includes <font name='Mono'>scripts/mcu_actor_network.R</font> as a separate advanced exercise. It uses <font name='Mono'>search_keyword()</font>, paginated movie retrieval, <font name='Mono'>movie_credits()</font>, and <font name='Mono'>igraph</font> to study actor collaboration. Complete this guide first, then follow the script's numbered comments.", "Bodyx"),
P("Before submitting work", "H2x")]
story += bullets(["Remove credentials from scripts, console screenshots, reports, and repository history.",
                  "Record the retrieval date, endpoint/filter choices, row count, and any truncation.",
                  "Attribute TMDB when publishing data or images and follow its current terms.",
                  "Keep the original <font name='Mono'>tmdbR_0.2.0.tar.gz</font> so your installation is reproducible."])
story += [P("<b>You are ready when:</b> <font name='Mono'>packageVersion(\"tmdbR\")</font> returns 0.2.0, <font name='Mono'>movie(id = 550)$title</font> succeeds, and your submitted files contain no credential.", "Callout"),
          HRFlowable(width="100%", thickness=0.6, color=LINE, spaceBefore=5, spaceAfter=5),
          P("Sources checked 8 August 2026: <link href='https://developer.themoviedb.org/docs/authentication-application' color='#0B6E99'>TMDB application authentication</link>; <link href='https://developer.themoviedb.org/docs/faq' color='#0B6E99'>TMDB FAQ</link>; local tmdbR 0.2.0 documentation and helper scripts.", "Small")]


def build():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    GuideDoc(str(OUT)).build(story)
    print(OUT)


if __name__ == "__main__":
    build()
