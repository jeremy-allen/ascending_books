library(gutenbergr)
library(tidyverse)
library(tidytext)

#---- prep ----

mirror_ky <- "https://mirror2.sandyriver.net/pub/gutenberg"
mirror_pg <- "https://gutenberg.pglaf.org"
mirror_al <- "https://aleph.gutenberg.org/"
mirror_xm <- "http://mirrors.xmission.com/gutenberg/"
mirror_bb <- "https://www.gutenberg.org/dirs/"
mirror_ny <- "https://gutenberg.nabasny.com/"
mirror_ca <- "http://mirror.csclub.uwaterloo.ca/gutenberg/"

#text <- gutenberg_download(2489, mirror = mirror_ca)
text <- readRDS("data/text.Rds")

not_sentence_ends <- tibble(
  with_periods = c("Mr.", "Ms.", "Mrs.", "St.", "ex.", "U.S.", "REV.", "V.E.",
  "A.D.", "B.C.", "Mt.", "EX.", "ST.", "i.", "ii.", "iii.", "iv.", "v.",
  "I.", "II.", "III.", "IV.", "V.")
) |> 
  mutate(with_underscores = str_replace_all(with_periods, "\\.", "_")) |> 
  mutate(with_slashes = str_replace_all(with_underscores, "_", "\\\\."))

#---- functions ----

drop_duplicate_blanks <- function(df) {

  empty_col <- "empty"
  dupe_col <- "dupe"

  while (empty_col %in% names(df)) {
    empty_col <- paste0("empty_", as.integer(runif(1, 100000, 999999)))
  }

  while (dupe_col %in% names(df)) {
    dupe_col <- paste0("dupe_", as.integer(runif(1, 100000, 999999)))
  }

  empty_col <- sym(empty_col)
  dupe_col <- sym(dupe_col)

  x <- df |> 
    mutate(
      {{empty_col}} := if_else(str_detect(text, "^."), FALSE, TRUE)
    ) |> 
    mutate(
      {{dupe_col}} := if_else(!!empty_col == TRUE & lag(!!empty_col) == TRUE, TRUE, FALSE)
    )

  y <- x |> 
    filter(!!dupe_col == FALSE) |> 
    select(-all_of(dupe_col))

  y

}

multiple_replacements <- function(string, patterns, replacements) {
  result <- string
  for (i in seq_along(patterns)) {
    result <- str_replace_all(result, patterns[i], replacements[i])
  }
  return(result)
}

#---- process the text ----

text <- text |> 
  mutate(
    original_row = row_number()
  ) |> 
  drop_duplicate_blanks() |> 
  # remove all above chp 1 (by keeping all after)
  slice(which(str_detect(text, "^CHAPTER"))[1]:n()) |> 
  # ids for paragraphs
  mutate(id_para = consecutive_id(empty)) |> 
  # combine rows that belong to same paragraph
  summarise(paras = paste(text, collapse = " "), .by = id_para) |> 
  # remove all blank lines
  filter(str_detect(paras, "^."))

# replace strings
text <- text |> 
  mutate(
    paras = map_chr(paras,
      multiple_replacements,
      patterns = not_sentence_ends$with_slashes,
      replacements = not_sentence_ends$with_underscores)
  )

# make each row a sentence
text <- text |> 
  unnest_sentences(text, paras, to_lower = FALSE) |> 
  # undo the string replacements we did previously
  mutate(
    text = map_chr(text,
      multiple_replacements,
      patterns = not_sentence_ends$with_underscores,
      replacements = not_sentence_ends$with_periods)
  )

# add columns for various sorting
text <- text |> 
  mutate(id_para = as.character(id_para)) |> 
  group_by(id_para) |>
  mutate(order_original = as.numeric(paste0(id_para, ".", row_number()))) |> 
  ungroup() |> 
  mutate(order_n_characters = nchar(text)) |> 
  select(-id_para)

text <- text |> 
  mutate(text2 = str_remove_all(text, "[^a-zA-Z0-9]")) |>  
  arrange(text2) |> 
  mutate(order_abc = as.integer(row_number())) |> 
  arrange(order_original) |> 
  select(text, order_original, order_abc, order_n_characters)

saveRDS(text, "data/text-clean.Rds")
