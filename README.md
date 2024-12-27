# ascending_books

This project creates a webpage that is the text of Moby Dick where each row is a sentence, and rows can be reordered.

Dwight Garner of The New York Times and Becca Rothfeld of The Washington Post discussed their 2024 book reviews with Kara Swisher [on an episode of Kara's podcast, On with Kara Swisher](https://podcasts.apple.com/us/podcast/the-best-and-most-overrated-books-of-2024/id1643307527?i=1000681397924).  

Dwight mentioned wanting to see Moby Dick in a format that allows reordering sentences alphabetically. So I made it!

## Read it here!

### Moby Dick - Ordered

At [https://pub.current.posit.team/public/moby/](https://pub.current.posit.team/public/moby/). Click a column header to reorder.

![](https://github.com/jeremy-allen/ascending_books/blob/d87f938b33965ce8f2b263cb08a2f3a496793757/moby-dick.png)

## How I did it

John Harmon's *[gutenbergr](https://docs.ropensci.org/gutenbergr/)* R package was used to retrieve the text from [Project Gutenberg](https://www.gutenberg.org/). Text processing was done with *[tidyverse](https://www.tidyverse.org/)* packages and the *[tidytext](https://juliasilge.github.io/tidytext/)* package by Julia Silge and David Robinson. This page was built with Posit's [Quarto](https://quarto.org/) framework and *[reactable](https://glin.github.io/reactable/index.html)* package. This page is hosted on a [Posit Connect](https://posit.co/products/enterprise/connect/) server.

