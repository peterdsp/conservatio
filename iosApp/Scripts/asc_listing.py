"""Puts Conservatio's App Store listing in place and, when asked, submits it for review.

Every step reads the current App Store Connect state first and writes the
listing again, so it is safe to run more than once.

    SUBMIT=0  listing, screenshots, age rating, review details, and the newest
              processed build of VERSION attached to the version
    SUBMIT=1  the same, then submit for App Review

The price is left alone unless PRICE_EUR is set, so a run never prices the app
by accident.

From a Mac with the signing-keys repo:

    ./iosApp/Scripts/submit-app-store.sh          listing only
    ./iosApp/Scripts/submit-app-store.sh submit   listing, then App Review
"""
import hashlib
import json
import os
import pathlib
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import jwt

ROOT = pathlib.Path(__file__).resolve().parent.parent
META = ROOT / "fastlane" / "metadata"
SHOTS = ROOT / "AppStore" / "marketing" / "en"
BUNDLE = "dev.peterdsp.conservatio"
VERSION = os.environ.get("VERSION", "0.1.0")
PRICE_EUR = os.environ.get("PRICE_EUR", "")
BASE_TERRITORY = "GRC"
# Every English storefront gets the same listing, whatever the primary locale is.
ENGLISH = ["en-US", "en-GB"]
SUBMIT = os.environ.get("SUBMIT") == "1"
API = "https://api.appstoreconnect.apple.com"
# 6.9" iPhone shots (1320x2868) go in the 6.7" set; 13" iPad shots (2064x2752) in the 12.9" set.
# iPhone Duo shots come from its cover screen, 1398x2034, one of its two sizes.
DISPLAY_TYPES = {"iphone": "APP_IPHONE_67", "ipad": "APP_IPAD_PRO_3GEN_129", "duo": "APP_IPHONE_DUO"}


def token():
    default = pathlib.Path.home() / "private_keys" / f"AuthKey_{os.environ['ASC_KEY_ID']}.p8"
    key = pathlib.Path(os.environ.get("ASC_KEY_PATH", default)).read_text()
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"]})


TOKEN = token()


def call(method, path, body=None, quiet=False):
    req = urllib.request.Request(API + path if path.startswith("/") else path,
                                 json.dumps(body).encode() if body is not None else None,
                                 {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            data = r.read()
            return json.loads(data) if data else {}
    except urllib.error.HTTPError as e:
        e.body = e.read().decode()
        if not quiet:
            print(f"::error::{method} {path} -> {e.code}: {e.body[:1500]}")
        raise


def text(name, locale="en-US"):
    """A listing field for one locale, falling back to the en-US text."""
    for folder in (locale, "en-US"):
        p = META / folder / f"{name}.txt"
        if p.exists():
            return p.read_text().strip()
    return None


def step(title):
    print(f"\n== {title}")


def main():
    step("App")
    app = call("GET", "/v1/apps?" + urllib.parse.urlencode({"filter[bundleId]": BUNDLE}))["data"][0]
    app_id = app["id"]
    print(app["attributes"]["name"], app_id)

    step("Content rights")
    call("PATCH", f"/v1/apps/{app_id}", {"data": {"type": "apps", "id": app_id,
         "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"}}})
    print("no third-party content")

    step("App info: name, subtitle, privacy URL, category")
    info = next(i for i in call("GET", f"/v1/apps/{app_id}/appInfos")["data"]
                if i["attributes"].get("appStoreState") not in ("READY_FOR_SALE", "REPLACED_WITH_NEW_INFO"))
    call("PATCH", f"/v1/appInfos/{info['id']}", {"data": {"type": "appInfos", "id": info["id"], "relationships": {
        "primaryCategory": {"data": {"type": "appCategories", "id": "PRODUCTIVITY"}},
        "secondaryCategory": {"data": {"type": "appCategories", "id": "BUSINESS"}}}}})
    locales = list(dict.fromkeys([app["attributes"]["primaryLocale"], *ENGLISH]))
    locs = call("GET", f"/v1/appInfos/{info['id']}/appInfoLocalizations")["data"]
    for locale in locales:
        attrs = {"name": text("name", locale), "subtitle": text("subtitle", locale), "privacyPolicyUrl": text("privacy_url", locale)}
        loc = next((l for l in locs if l["attributes"]["locale"] == locale), None)
        if loc:
            call("PATCH", f"/v1/appInfoLocalizations/{loc['id']}", {"data": {"type": "appInfoLocalizations", "id": loc["id"], "attributes": attrs}})
        else:
            call("POST", "/v1/appInfoLocalizations", {"data": {"type": "appInfoLocalizations", "attributes": {"locale": locale, **attrs},
                 "relationships": {"appInfo": {"data": {"type": "appInfos", "id": info["id"]}}}}})
        print(locale, attrs)

    step("Age rating: 4+")
    rating = call("GET", f"/v1/appInfos/{info['id']}/ageRatingDeclaration")["data"]
    present = set(rating["attributes"])
    # Conservatio has none of this content, so every frequency is NONE and every
    # yes/no is no. Records stay with the person who made them, so there is no
    # user-generated content shared with others.
    frequency = ["alcoholTobaccoOrDrugUseOrReferences", "contests", "gamblingSimulated", "gunsOrOtherWeapons",
                 "horrorOrFearThemes", "matureOrSuggestiveThemes", "medicalOrTreatmentInformation",
                 "profanityOrCrudeHumor", "sexualContentGraphicAndNudity", "sexualContentOrNudity",
                 "violenceCartoonOrFantasy", "violenceRealistic", "violenceRealisticProlongedGraphicOrSadistic"]
    yes_no = ["gambling", "unrestrictedWebAccess", "lootBox", "messagingAndChat", "parentalControls",
              "ageAssurance", "userGeneratedContent", "advertising", "healthOrWellnessTopics"]
    none_fields = {k: "NONE" for k in frequency if k in present}
    false_fields = {k: False for k in yes_no if k in present}
    answers = {**none_fields, **false_fields}
    # Apple keeps adding questions; answer each newly required one with "no"
    # (or "none" when it is a frequency) and try again.
    for _ in range(25):
        try:
            call("PATCH", f"/v1/ageRatingDeclarations/{rating['id']}", {"data": {"type": "ageRatingDeclarations", "id": rating["id"],
                 "attributes": answers}}, quiet=True)
            break
        except urllib.error.HTTPError as e:
            err = json.loads(e.body)["errors"][0]
            field = err.get("source", {}).get("pointer", "").rsplit("/", 1)[-1]
            if err["code"] == "ENTITY_ERROR.ATTRIBUTE.REQUIRED" and field not in answers:
                answers[field] = False
            elif err["code"].startswith("ENTITY_ERROR.ATTRIBUTE.") and answers.get(field) is False:
                answers[field] = "NONE"
            else:
                print(f"::error::age rating: {err['code']} {err.get('detail')}")
                raise
        print(f"answered {field} = {answers[field]}")
    else:
        sys.exit("age rating: too many new questions")
    none_fields = {k: v for k, v in answers.items() if v == "NONE"}
    false_fields = {k: v for k, v in answers.items() if v is False}
    print(f"{len(none_fields)} content questions NONE, {len(false_fields)} yes/no questions NO")

    step(f"Version {VERSION}")
    versions = call("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=50")["data"]
    version = next((v for v in versions if v["attributes"]["versionString"] == VERSION), None)
    editable = ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY")
    draft = next((v for v in versions if (v["attributes"].get("appStoreState") or v["attributes"].get("appVersionState")) in editable), None)
    if not version and draft:
        # A new app comes with a first version already; give it this number.
        old_number = draft["attributes"]["versionString"]
        version = call("PATCH", f"/v1/appStoreVersions/{draft['id']}", {"data": {"type": "appStoreVersions", "id": draft["id"],
                       "attributes": {"versionString": VERSION}}})["data"]
        print(f"renamed {old_number} to {VERSION}")
    if not version:
        version = call("POST", "/v1/appStoreVersions", {"data": {"type": "appStoreVersions",
                       "attributes": {"platform": "IOS", "versionString": VERSION, "releaseType": "AFTER_APPROVAL"},
                       "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}})["data"]
        print("created")
    ver_id = version["id"]
    state = version["attributes"].get("appStoreState") or version["attributes"].get("appVersionState")
    print(f"{ver_id} state={state}")
    if state not in (None, "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY"):
        print(f"Version {VERSION} is {state}; nothing to change.")
        return
    call("PATCH", f"/v1/appStoreVersions/{ver_id}", {"data": {"type": "appStoreVersions", "id": ver_id,
         "attributes": {"releaseType": "AFTER_APPROVAL", "copyright": f"{time.gmtime().tm_year} Petros Dhespollari"}}})

    vlocs = call("GET", f"/v1/appStoreVersions/{ver_id}/appStoreVersionLocalizations")["data"]
    for locale in locales:
        step(f"Listing text and screenshots: {locale}")
        vattrs = {"description": text("description", locale), "keywords": text("keywords", locale),
                  "promotionalText": text("promotional_text", locale),
                  "marketingUrl": text("marketing_url", locale), "supportUrl": text("support_url", locale)}
        ven = next((l for l in vlocs if l["attributes"]["locale"] == locale), None)
        if ven:
            call("PATCH", f"/v1/appStoreVersionLocalizations/{ven['id']}", {"data": {"type": "appStoreVersionLocalizations", "id": ven["id"], "attributes": vattrs}})
        else:
            ven = call("POST", "/v1/appStoreVersionLocalizations", {"data": {"type": "appStoreVersionLocalizations",
                       "attributes": {"locale": locale, **vattrs},
                       "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}}}})["data"]
        upload_screenshots(ven["id"])

    if PRICE_EUR:
        set_price(app_id)
    else:
        step("Price")
        print("skipped: no PRICE_EUR given, the price stays as it is in App Store Connect")

    step("App Review details")
    review_notes = (META / "review_information" / "notes.txt").read_text().strip()
    contact = {"contactFirstName": "Petros", "contactLastName": "Dhespollari", "contactEmail": "info@peterdsp.dev"}
    phone = os.environ.get("REVIEW_PHONE") or copy_review_phone(app_id)
    if phone:
        contact["contactPhone"] = phone
    rattrs = {**contact, "notes": review_notes, "demoAccountRequired": False}
    try:
        detail = call("GET", f"/v1/appStoreVersions/{ver_id}/appStoreReviewDetail")["data"]
    except urllib.error.HTTPError:
        detail = None
    if detail:
        call("PATCH", f"/v1/appStoreReviewDetails/{detail['id']}", {"data": {"type": "appStoreReviewDetails", "id": detail["id"], "attributes": rattrs}})
    else:
        call("POST", "/v1/appStoreReviewDetails", {"data": {"type": "appStoreReviewDetails", "attributes": rattrs,
             "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}}}})
    print("contact and notes set" + ("" if phone else " (no phone found: add REVIEW_PHONE or fill it in App Store Connect)"))

    step("Build")
    builds = call("GET", f"/v1/builds?filter[app]={app_id}&filter[preReleaseVersion.version]={VERSION}"
                         "&filter[processingState]=VALID&sort=-uploadedDate&limit=1")["data"]
    if not builds:
        print(f"::error::No processed {VERSION} build yet. Wait for processing, then re-run.")
        sys.exit(1)
    build = builds[0]
    if build["attributes"].get("usesNonExemptEncryption") is None:
        # The app only uses the encryption built into iOS (HTTPS), which is exempt.
        call("PATCH", f"/v1/builds/{build['id']}", {"data": {"type": "builds", "id": build["id"],
             "attributes": {"usesNonExemptEncryption": False}}})
        print("export compliance: uses only exempt encryption")
    call("PATCH", f"/v1/appStoreVersions/{ver_id}/relationships/build", {"data": {"type": "builds", "id": build["id"]}})
    print(f"attached build {build['attributes']['version']}")

    if not SUBMIT:
        print("\nListing is in place. Run again with submit to send it to App Review.")
        return

    step("Submit for review")
    # Reuse a submission left open by an earlier, interrupted run.
    open_subs = call("GET", f"/v1/reviewSubmissions?filter[app]={app_id}&filter[platform]=IOS&filter[state]=READY_FOR_REVIEW")["data"]
    sub = open_subs[0] if open_subs else call("POST", "/v1/reviewSubmissions", {"data": {"type": "reviewSubmissions",
               "attributes": {"platform": "IOS"}, "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}})["data"]
    items = call("GET", f"/v1/reviewSubmissions/{sub['id']}/items")["data"]
    if not items:
        call("POST", "/v1/reviewSubmissionItems", {"data": {"type": "reviewSubmissionItems", "relationships": {
            "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub["id"]}},
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver_id}}}}})
    call("PATCH", f"/v1/reviewSubmissions/{sub['id']}", {"data": {"type": "reviewSubmissions", "id": sub["id"], "attributes": {"submitted": True}}})
    print(f"Submitted Conservatio {VERSION} for App Review. It goes on sale automatically once approved.")


def set_price(app_id):
    step(f"Price: {PRICE_EUR} EUR, base territory {BASE_TERRITORY}")
    points, url = [], f"/v1/apps/{app_id}/appPricePoints?" + urllib.parse.urlencode({"filter[territory]": BASE_TERRITORY, "limit": 200})
    while url:
        page = call("GET", url)
        points += page["data"]
        url = page.get("links", {}).get("next")
    point = next((p for p in points if p["attributes"]["customerPrice"] == PRICE_EUR), None)
    if not point:
        near = sorted({p["attributes"]["customerPrice"] for p in points}, key=lambda v: abs(float(v) - float(PRICE_EUR)))[:6]
        print(f"::error::No {PRICE_EUR} EUR price point; nearest: {near}")
        sys.exit(1)
    call("POST", "/v1/appPriceSchedules", {
        "data": {"type": "appPriceSchedules", "relationships": {
            "app": {"data": {"type": "apps", "id": app_id}},
            "baseTerritory": {"data": {"type": "territories", "id": BASE_TERRITORY}},
            "manualPrices": {"data": [{"type": "appPrices", "id": "${price}"}]}}},
        "included": [{"type": "appPrices", "id": "${price}", "attributes": {"startDate": None},
                      "relationships": {"appPricePoint": {"data": {"type": "appPricePoints", "id": point["id"]}}}}]})
    print(f"set {PRICE_EUR} EUR, other territories follow Apple's equalisation")


def upload_screenshots(loc_id):
    """Replaces the iPhone and iPad screenshot sets of one listing with the marketing images."""
    sets = call("GET", f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets")["data"]
    for device, display in DISPLAY_TYPES.items():
        files = sorted((SHOTS / device).glob("*.png"))
        shot_set = next((s for s in sets if s["attributes"]["screenshotDisplayType"] == display), None)
        if shot_set:
            for old in call("GET", f"/v1/appScreenshotSets/{shot_set['id']}/appScreenshots")["data"]:
                call("DELETE", f"/v1/appScreenshots/{old['id']}")
        else:
            shot_set = call("POST", "/v1/appScreenshotSets", {"data": {"type": "appScreenshotSets",
                            "attributes": {"screenshotDisplayType": display},
                            "relationships": {"appStoreVersionLocalization": {"data": {"type": "appStoreVersionLocalizations", "id": loc_id}}}}})["data"]
        for f in files:
            data = f.read_bytes()
            shot = call("POST", "/v1/appScreenshots", {"data": {"type": "appScreenshots",
                        "attributes": {"fileName": f.name, "fileSize": len(data)},
                        "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": shot_set["id"]}}}}})["data"]
            for op in shot["attributes"]["uploadOperations"]:
                chunk = data[op["offset"]:op["offset"] + op["length"]]
                req = urllib.request.Request(op["url"], chunk, {h["name"]: h["value"] for h in op["requestHeaders"]}, method=op["method"])
                urllib.request.urlopen(req).read()
            call("PATCH", f"/v1/appScreenshots/{shot['id']}", {"data": {"type": "appScreenshots", "id": shot["id"],
                 "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
            print(f"{display}: {f.name}")


def copy_review_phone(app_id):
    """Reuses the App Review phone already on another of the team's apps."""
    for app in call("GET", "/v1/apps?limit=50")["data"]:
        if app["id"] == app_id:
            continue
        for v in call("GET", f"/v1/apps/{app['id']}/appStoreVersions?limit=3")["data"]:
            try:
                d = call("GET", f"/v1/appStoreVersions/{v['id']}/appStoreReviewDetail")["data"]
            except urllib.error.HTTPError:
                continue
            if d and d["attributes"].get("contactPhone"):
                return d["attributes"]["contactPhone"]
    return None


if __name__ == "__main__":
    main()
