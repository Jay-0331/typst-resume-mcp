// Helper Functions

#let monthname(n, display: "short") = {
    n = int(n)
    let month = ""

    if display == "short" {
        if n == 1 { month = "Jan" }
        else if n == 2 { month = "Feb" }
        else if n == 3 { month = "Mar" }
        else if n == 4 { month = "Apr" }
        else if n == 5 { month = "May" }
        else if n == 6 { month = "Jun" }
        else if n == 7 { month = "Jul" }
        else if n == 8 { month = "Aug" }
        else if n == 9 { month = "Sep" }
        else if n == 10 { month = "Oct" }
        else if n == 11 { month = "Nov" }
        else if n == 12 { month = "Dec" }
    } else if display == "long" {
        if n == 1 { month = "January" }
        else if n == 2 { month = "February" }
        else if n == 3 { month = "March" }
        else if n == 4 { month = "April" }
        else if n == 5 { month = "May" }
        else if n == 6 { month = "June" }
        else if n == 7 { month = "July" }
        else if n == 8 { month = "August" }
        else if n == 9 { month = "September" }
        else if n == 10 { month = "October" }
        else if n == 11 { month = "November" }
        else if n == 12 { month = "December" }
    } else if display == "number" {
        if n == 1 { month = "01" }
        else if n == 2 { month = "02" }
        else if n == 3 { month = "03" }
        else if n == 4 { month = "04" }
        else if n == 5 { month = "05" }
        else if n == 6 { month = "06" }
        else if n == 7 { month = "07" }
        else if n == 8 { month = "08" }
        else if n == 9 { month = "09" }
        else if n == 10 { month = "10" }
        else if n == 11 { month = "11" }
        else if n == 12 { month = "12" }
    }
    return month
}

#let strpdate(isodate) = {
    let date = ""
    if type(isodate) == str and lower(isodate) == "present" {
        date = "Present"
    } else {
        let dateStr = str(isodate)
        let year = int(dateStr.slice(0, 4))
        let month = int(dateStr.slice(5, 7))
        let day = int(dateStr.slice(8, 10))
        let monthName = monthname(month, display: "number")
        date = datetime(year: year, month: month, day: day)
        date = monthName + "/" + date.display("[year repr:full]")
    }
    return date
}

#let daterange(start, end) = {
    if start != none and end != none [
        #start #sym.dash.en #end
    ]
    if start == none and end != none [
        #end
    ]
    if start != none and end == none [
        #start
    ]
}