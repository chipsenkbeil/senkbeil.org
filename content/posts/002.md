+++
title = "CSS Masonry Layout Attempts"
slug = "css-masonry-layout-attempts"
date = "2015-09-02"
categories = [ "experiment" ]
tags = [ "css" ]
+++

I spent two days investigating this and could not find a solution that worked.
Eventually, I gave up and added the Masonry Javascript library. My two
attempts were as follows:

### Using CSS Columns

CSS Columns enabled an easy, powerful way to spread page summaries across
multiple columns. Furthermore, you can prevent page summaries from being
broken up in the middle by using `column-break-inside: avoid;`. However, I had
no way to order the page summaries dynamically such that the most recent
summaries were at the top (from left to right) and older summaries were found
further down. Instead, this resulted in the latest summary starting in the top
left with older summaries going down the first column and into the second, etc.

```css
.page-summary-container {
    -moz-column-count: 3;
    -webkit-column-count: 3;
    column-count: 3;

    -moz-column-gap: 0;
    -webkit-column-gap: 0;
    column-gap: 0;
}

.page-summary {
    display: inline-block;
    -webkit-column-break-inside: avoid; /* Chrome, Safari */
    -moz-column-break-inside:avoid;
    -o-column-break-inside:avoid;
    -ms-column-break-inside:avoid;
    column-break-inside:avoid;
    page-break-inside: avoid;           /* Theoretically FF 20+ */
    break-inside: avoid-column;         /* IE 11 */
}
```

### Using Flexbox

This involved using flexbox to simulate a Masonry layout by using
`flex-flow: column wrap` to have items flow from top to bottom with no extra
spacing (similar to Masonry). There were two issues with this approach: page
summaries still flowed from top to bottom instead of left to right and
I couldn't control wrapping the column into the next column without providing
a fixed-height container.

The first issue was able to be solved by swapping the order of the elements,
which you can do in flexbox. Since the list page is using pagination (meaning
that I can guarantee the total page summaries per page), ordering the elements
was as simple as adding child selectors to break up the order based on the
number of elements:

```css
.page-summary:nth-child(3n+1) {
    order: 1;
}

.page-summary:nth-child(3n+2) {
    order: 2;
}

.page-summary:nth-child(3n) {
    order: 3;
}
```

Unfortunately, as I couldn't provide a fixed-height container, the column
approach did not work as all elements stayed in the first column. I could not
find any working way to forcefully wrap flexbox elements after a certain
element when using _column_ as the flow instead of _row_ (where you can set
the row item to a width of _100%_).

I could have forced a specific height for the page summaries as I know how big
the text will be (roughly) if I use an ellipsis for overflow on the title (and
the summary is always 70 words max). However, the optional image throws off my
sizing estimates.

