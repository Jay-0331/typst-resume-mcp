#import "cv.typ": *

#let cvdata = yaml("Resume_Modify.yml")

#let uservars = (
    headingfont: "Inter",
    bodyfont: "Inter",

    fontsize: 11pt,
    linespacing: 7pt,
    sectionspacing: -2pt,
    
    showAddress: true,
    showNumber: true,
    showTitle: false,
    headingsmallcaps: false,

    linkcolor: rgb("#1f6feb"),
)

#let customrules(doc) = {
    set page(
        paper: "a4",
        numbering: none,
        margin: 1.1cm,
    )
    doc
}

#let cvinit(doc) = {
    doc = setrules(uservars, doc)
    doc = showrules(uservars, doc)
    doc = customrules(doc)
    doc
}

// ========================================================================== //

#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)
// #cvsummary(cvdata)
#cvwork(cvdata)
#cvskills(cvdata)
#cvprojects(cvdata)
#cveducation(cvdata)