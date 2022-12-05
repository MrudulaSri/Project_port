library(tidyverse)
library(tm)
library(wordcloud2)

link <- "https://www.gutenberg.org/files/1342/1342-0.txt"

pride <- read_lines(link, skip = 0, skip_empty_rows = TRUE)

pride1 <- gsub('[^[:alnum:]]', ' ', pride)

#data cleaning
#corpus
book <- Corpus(VectorSource(pride1))

#remove punctuation
pride_clean <- tm_map(book, removePunctuation)

#to lowercase
pride_clean <- tm_map(pride_clean, content_transformer(tolower))

#remove numbers
pride_clean <- tm_map(pride_clean, removeNumbers)

#remove stopwords
n_distinct(stopwords('SMART'))
head(stopwords('SMART'), n = 10)

pride_clean <- tm_map(pride_clean, removeWords, c(stopwords('SMART'), 'chapter'))

#term-document matrix
tdm <- TermDocumentMatrix(pride_clean)
tdm

#remove sparse terms
tdm2 <- removeSparseTerms(tdm, sparse = 0.99)
tdm2

#matrix
mat <- as.matrix(tdm2)

#vector
vec <- sort(rowSums(mat), decreasing = TRUE)

#data frame
pride_and_prejudice <- tibble(term = names(vec), freq = vec)
print(pride_and_prejudice, n = 28)

#wordcloud
wordcloud2(data = pride_and_prejudice, size = 0.7, color = 'random-light', 
           backgroundColor = '#281E5D', shape = 'circle')

#bar charts
pride_and_prejudice %>%
  head(10) %>%
  ggplot() + 
  geom_col(mapping = aes(x = term, y = freq), color = "black", fill = "#610C04",
           position = 'dodge') +
  geom_text(aes(x = term, y = freq, label = freq), vjust = 0.3, hjust = 1.2,
            color = "white", size = 3.0) +
  labs(title = "Most frequently used words") +
  coord_flip()