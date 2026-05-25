#import "utils.typ"

#let sep = [ *|* ]

// Reusable block aliases
#let entryblock(isbreakable: true, body) = block(width: 100%, breakable: isbreakable, above: 0.6em, below: 0pt, body)
#let subblock(isbreakable: true, body) = block(width: 100%, breakable: isbreakable, above: 0.4em, below: 0pt, body)

// ==================== Document Rules ==================== //

#let setrules(uservars, doc) = {
    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}

#let showrules(uservars, doc) = {
    show heading.where(level: 2): it => block(width: 100%, below: 0pt)[
        #v(uservars.sectionspacing)
        #set align(left)
        #set text(font: uservars.headingfont, size: 1.05em, weight: "bold")
        #it.body
        #v(-0.8em) #line(length: 100%, stroke: 1pt + black)
    ]

    show heading.where(level: 1): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.3em, weight: "extrabold")
        #it.body
    ]

    show link: set text(fill: uservars.linkcolor)

    doc
}

// ==================== Header Components ==================== //

#let jobtitletext(info, uservars) = {
    if uservars.showTitle {
        block(width: 100%, above: 0pt, below: 0.4em)[
            *#info.personal.titles.join(sep)*
        ]
    } else { none }
}

#let cvheading(info, uservars) = {
    // Build contact + address items into one line
    let items = ()
    if uservars.showAddress {
        let address = info.personal.location.pairs().filter(it => it.at(1) != none and str(it.at(1)) != "")
        let location = address.map(it => str(it.at(1))).join(", ")
        items.push(box(location))
    }
    if uservars.showNumber {
        items.push(box(link("tel:" + info.personal.phone)))
    }
    items.push(box(link("mailto:" + info.personal.email)))
    if ("profiles" in info.personal) and (info.personal.profiles.len() > 0) {
        for profile in info.personal.profiles {
            items.push(box(link(profile.url)[#profile.network]))
        }
    }
    if info.personal.url != none {
        items.push(box(link(info.personal.url)[#info.personal.url.split("//").at(1)]))
    }

    align(center)[
        = #info.personal.name
        #v(-1pt)
        #jobtitletext(info, uservars)
        #block(width: 100%, above: 0pt, below: 1.1em)[
            #set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize)
            #items.join(sep)
        ]
    ]
}

// ==================== Section Components ==================== //

#let cvsummary(info, title: "Summary", isbreakable: true) = {
    if ("summary" in info) and (info.summary != none) and (info.summary != "") {block[
        == #title
        #entryblock(isbreakable: isbreakable)[
            #eval(info.summary, mode: "markup")
        ]
    ]}
}

#let cveducation(info, title: "Education", isbreakable: true) = {
    if ("education" in info) and (info.education != none) {block[
        == #title
        #for edu in info.education {
            let start = utils.strpdate(edu.startDate)
            let end = utils.strpdate(edu.endDate)

            entryblock(isbreakable: isbreakable)[
                *#edu.institution*
                #if ("gpa" in edu) and (edu.gpa != none) [
                    #sep GPA: #edu.gpa
                ]
                #h(1fr) *#edu.location* \
                #text(style: "italic")[#edu.studyType, #edu.area]
                #h(1fr) #utils.daterange(start, end) \
            ]
        }
    ]}
}

#let cvwork(info, title: "Experience", isbreakable: true) = {
    if ("work" in info) and (info.work != none) {block[
        == #title
        #for w in info.work {
            entryblock(isbreakable: isbreakable)[
                *#w.organization* #h(1fr) *#w.location* \
            ]
            let index = 0
            for p in w.positions {
                subblock(isbreakable: isbreakable)[
                    #let start = utils.strpdate(p.startDate)
                    #let end = utils.strpdate(p.endDate)
                    #text(style: "italic")[#p.position] #h(1fr)
                    #utils.daterange(start, end) \
                    #for hi in p.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                ]
                index = index + 1
            }
        }
    ]}
}

#let cvprojects(info, title: "Projects", isbreakable: true) = {
    if ("projects" in info) and (info.projects != none) {block[
        == #title
        #for project in info.projects {
            entryblock(isbreakable: isbreakable)[
                #if ("url" in project) and (project.url != none) and (project.url != "") [
                    *#link(project.url)[#project.name]* #sep
                ] else [
                    *#project.name* #sep
                ]
                #if ("techstack" in project) and (project.techstack != none) [
                    #h(0.1em) #text(style: "italic")[#project.techstack]
                ]
                \
                #if ("highlights" in project) and (project.highlights != none) {
                    for hi in project.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                }
            ]
        }
    ]}
}

#let cvskills(info, title: "Technical Skills", isbreakable: true) = {
    if ("skills" in info) and (info.skills != none) {block(breakable: isbreakable)[
        == #title
        #entryblock()[
          #for group in info.skills [
              - *#group.category*: #group.skills.join(", ")
          ]
        ]
    ]}
}