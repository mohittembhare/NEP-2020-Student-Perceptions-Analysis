library(readxl)
library(dplyr)
library(ggplot2)
library(corrplot)

#Load the Data
file_path <- "C:/Users/MOHIT TEMBHARE/Desktop/NEP2020_Survey_Responses.xlsx"
df <- read_excel(file_path, sheet = "Survey Data")

#Data Cleaning (ignoring ID, Timestamp, and Source)
df_questions <- df %>% select(starts_with("Q"))

#Convert all data to numeric for correlation
df_questions <- data.frame(lapply(df_questions, as.numeric))

#Descriptive Statistics (Means)
means <- colMeans(df_questions, na.rm = TRUE)
print("Top 5 Highest Rated Questions (Mean Scores):")
print(sort(means, decreasing = TRUE)[1:5])

#Correlation Analysis (Using Spearman's correlation)
cor_matrix <- cor(df_questions, method = "spearman", use = "complete.obs")

#Extracting Strongest Correlations
# Flatten matrix and filter out self-correlations (1.0)
cor_df <- as.data.frame(as.table(cor_matrix))
cor_df <- cor_df %>% 
  filter(Var1 != Var2) %>% 
  arrange(desc(Freq))

#Remove duplicates (e.g., A-B is the same as B-A)
cor_df <- cor_df[!duplicated(t(apply(cor_df[,1:2], 1, sort))),]

print("Top 5 Strongest Positive Correlations:")
head(cor_df, 5)

print("Top 5 Weakest/Negative Correlations:")
tail(cor_df %>% arrange(Freq), 5)

#Visualization: Correlation Heatmap
png("Correlation_Heatmap.png", width = 800, height = 800)
corrplot(cor_matrix, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45, 
         title = "Spearman Correlation of NEP 2020 Survey Perceptions",
         mar=c(0,0,2,0))
dev.off()
print("Heatmap saved as 'Correlation_Heatmap.png'")