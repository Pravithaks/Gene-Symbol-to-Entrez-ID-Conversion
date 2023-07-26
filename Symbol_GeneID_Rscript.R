#GeneSymbolToEntrezIDConversion
library(readr)
library(dplyr)
library(tidyr)

# Read the GMT file into a data frame
gene_info <- read_delim("/home/mvrccri/Downloads/KMC/Homo_sapiens.gene_info.gz", delim = "\t")

# Select the 3 columns you want to read
selected_columns <- gene_info %>% select(GeneID, Symbol, Synonyms)

# Create a map of Symbol to GeneId
symbol_to_geneid <- gene_info %>%
  mutate(Synonyms = strsplit(Synonyms, "\\|")) %>%
  unnest(cols = Synonyms) %>%
  select(Symbol, GeneID) %>%
  distinct()

# Read the GMT file
GMT_file <- read_lines("/home/mvrccri/Downloads/KMC/h.all.v2023.1.Hs.symbols.gmt")

# Replace gene symbols with Entrez IDs in GMT file
output_lines <- character()
for (line in GMT_file) {
  fields <- strsplit(line, "\t")[[1]]
  pathway_name <- fields[1]
  pathway_description <- fields[2]
  genes <- fields[-c(1, 2)]
  
  # Replace symbols with Entrez IDs if they exist in the mapping
  entrez_ids <- symbol_to_geneid[match(genes, symbol_to_geneid$Symbol), "GeneID"]
  output_line <- paste(c(pathway_name, pathway_description, entrez_ids), collapse = "\t")
  output_lines <- c(output_lines, output_line)
}

# Write the output to a new GMT file
output_file <- "/home/mvrccri/Downloads/KMC/h.all.v2023.1.Hs.entrez_ids.gmt"
writeLines(output_lines, con = output_file)
cat("New GMT file with Entrez IDs has been created:", output_file, "\n")