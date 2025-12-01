
install.packages("dplyr")
install.packages("tidyr")

library(dplyr)
library(tidyr)
library(readr)
library(stringr)
raw_data <- read_csv("C:/Users/LENOVO/Downloads/Consumer Profiling and Online Shopping Behavior  (Responses) - Form Responses 1 (1).csv")
View(raw_data)


#prview data
head(raw_data,n = 5)

#Check data types of all columns
str(raw_data2)

#check null and na
sum(is.na(raw_data))
sum(is.null(raw_data))


#remove the time stamp column
raw_data1 <- raw_data[ , -1]
View(raw_data1)



#Column names: remove spaces, symbols, inconsistent capitalization

raw_data2 <- raw_data1 %>%  
  rename(
    Gender = "What is your gender?",
    Age = "How old are you?",
    Is_student = "Are you a student?",
    Occupation = "What is your current occupation status?",
    Spending_Willing = "How much money are you willing to spend per month on online shopping?   (VND)",
    Spending_Average = "Your average spending per month on online shopping: (VND)",
    Shop_Frequency = "How frequently do you shop online?",
    Product_Category = "Which product categories do you buy most often online? (Select all that apply)",
    Special_Occasion = "On which special occasions do you shop online? (Select all that apply)",
    Discount_Importance = "How important are discounts when you shop online?",
    Promotion_Type = "What type of promotions influence your purchase the most? (Select all that apply)",
    Switch_Platform_Likelihood = "How likely are you to switch platforms (e.g., from Shopee to Lazada) to get a better discount?",
    Compare_Frequency = "How often do you compare prices across multiple platforms before buying? \n",
    Review_Importance = "How important are product reviews in your purchase decision?",
    Review_Read_Frequency = "How often do you read customer reviews before buying?",
    Mixed_Review_Action = "If a product has mixed reviews (both good and bad), what do you usually do?   (Select all that apply)",
    Main_Platform = "Which platform do you use the most for online shopping?  (Select all that apply)",
    Marketing_Channel = "Which online marketing channels influence your shopping decisions the most? (Select all that apply)",
    Frustration_Issues = "What issues cause you the most frustration when shopping online?  \n(Select all that apply)"
  )
raw_data2

#Remove leading/trailing whitespace in names -> not have any 
#Fix encoding issues (weird characters, wrong UTF-8 display) -> not have any
# Remove completely empty columns -> not have any
#Detect mixed-type columns (e.g., numbers stored with text like “10kg”) -> not have any




#handle age column
table(raw_data2$Age)

raw_data2 <- raw_data2 %>%
  # Replace individual Age values with the midpoint of the user-defined range.
  mutate(
    Age = case_when(
      Age >= 15 & Age <= 20 ~ 17.5, # Midpoint of 15-20
      Age >= 21 & Age <= 30 ~ 25.5, # Midpoint of 21-30
      Age >= 31 & Age <= 40 ~ 35.5, # Midpoint of 31-40
      Age >= 41 & Age <= 50 ~ 45.5, # Midpoint of 41-50
      # Handle ages outside 15-50 range, if any exist.
      TRUE ~ NA_real_ # Use NA_real_ for numerical NA
    )
  )

#handle gender column
install.packages("fastDummies")
library(fastDummies)

table(raw_data2$Gender)

#remove outliers


raw_data2 <- raw_data2 %>%
  mutate(
    Gender = case_when(
      Gender %in% c("Prefer not.", "Prefer not say") ~ "Other",
      TRUE ~ Gender
    )
  )

raw_data3 <- fastDummies::dummy_cols(
  raw_data2,
  select_columns = "Gender",
  remove_first_dummy = FALSE, 
  remove_selected_columns = TRUE
)
#remove the column Other if not necessary
raw_data3 <- raw_data3 %>%
  select(-starts_with("Gender_Other"))
View(raw_data3)

#handle is_student
table(raw_data3$Is_student)
#1 = yes, 2 =no 
raw_data3$Is_student <- ifelse(raw_data3$Is_student == "Yes", 1, 0)

#handle occupation
table(raw_data3$Occupation)
raw_data4 <- fastDummies::dummy_cols(
  raw_data3,
  select_columns = "Occupation",
  remove_selected_columns = TRUE
)

# Clean the names of the newly created dummy columns
raw_data4 <- raw_data4 %>% 
  rename_with(~tolower(gsub(" ", "_", gsub("Occupation_", "Occupation_", .))), 
              starts_with("Occupation_"))


View(raw_data4)
#handle spending_willing
#Preserves order and numeric scale
#Keeps dataset compact (one column)
#Distance between points is meaningful for clustering
#Simple to implement and interpret
table(raw_data4$Spending_Willing)
raw_data4$Spending_Willing <- recode(raw_data4$Spending_Willing,
                                             "Below 200,000" = 100000,
                                             "From 200,000 to below 500,000" = 350000,
                                             "From 500,000 to below 1.000,000" = 750000,
                                             "1.000,000 or above" = 1000000)

#handle spending_average
raw_data4$Spending_Average <- recode(raw_data4$Spending_Average,
                                     "Below 200,000" = 100000,
                                     "From 200,000 to below 500,000" = 350000,
                                     "From 500,000 to below 1.000,000" = 750000,
                                     "1.000,000 or above" = 1000000)

#handle shop_frequency
table(raw_data4$Shop_Frequency)
raw_data4$Shop_Frequency <- factor(
  raw_data4$Shop_Frequency,
  levels = c("Once a month or less",
             "2–3 times a month",
             "Once a week",
             "2–3 times a week",
             "Daily / Almost Daily"),
  ordered = TRUE
)
raw_data4$Shop_Frequency <- as.numeric(raw_data4$Shop_Frequency)

#handle discount importance

raw_data5<- copy(raw_data4)
raw_data5$Shop_Frequency <- raw_data5$Shop_Frequency %>%
  str_replace_all("–", "-") %>%        # normalize dash
  str_replace_all("2–3", "2-3") %>%    # fix "2–3" unicode
  str_replace_all("2–3", "2-3") %>%
  str_replace_all(" / ", "_") %>%      # replace spaces around /
  str_replace_all("/", "_") %>%
  str_to_lower() %>%                   # make lowercase
  str_trim() %>%                       # remove leading/trailing space
  str_replace_all(" ", "_")            # spaces to underscore


raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Shop_Frequency",
    split = ",",
    remove_selected_columns = TRUE
  )

#handle switch platform likehood, compare frequency, review important, review read recency
raw_data5$Switch_Platform_Likelihood <- raw_data5$Switch_Platform_Likelihood %>%
  str_to_lower() %>%                # lowercase
  str_trim() %>%                    # remove extra space
  str_replace_all("–", "_") %>%
  str_replace_all("/", "_") %>%
  str_replace_all(" ", "_") %>%     # spaces → underscores
  str_replace_all("[^a-z0-9_]", "") 


raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Switch_Platform_Likelihood",
    split = ",",
    remove_selected_columns = TRUE
  )


#handle compare frequency
raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Compare_Frequency",
    split = ",",
    remove_selected_columns = TRUE
  )


#handle review important
raw_data5$Review_Importance <- raw_data5$Review_Importance %>%
  str_to_lower() %>%                # lowercase
  str_trim() %>%                    # remove extra space
  str_replace_all("–", "_") %>%
  str_replace_all("/", "_") %>%
  str_replace_all(" ", "_") %>%     # spaces → underscores
  str_replace_all("[^a-z0-9_]", "") 
raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Review_Importance",
    split = ",",
    remove_selected_columns = TRUE
  )


#handle review read frequence
raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Review_Read_Frequency",
    split = ",",
    remove_selected_columns = TRUE
  )

#handle discount important
raw_data5$Discount_Importance <- raw_data5$Discount_Importance %>%
  str_to_lower() %>%                # lowercase
  str_trim() %>%                    # remove extra space
  str_replace_all("–", "_") %>%
  str_replace_all("/", "_") %>%
  str_replace_all(" ", "_") %>%     # spaces → underscores
  str_replace_all("[^a-z0-9_]", "") 
raw_data5 <- raw_data5 %>%
  dummy_cols(
    select_columns = "Discount_Importance",
    split = ",",
    remove_selected_columns = TRUE
  )

#handle product category
unique(raw_data6$Product_Category)

raw_data6 <- copy(raw_data5)

raw_data6$Product_Category <- raw_data6$Product_Category %>%
  # 1. Simplify core category names
  gsub("Fashion \\(clothes, shoes, etc.\\)", "Fashion", .) %>%
  gsub("Beauty & skincare", "Beauty", .) %>%
  gsub("Electronics & gadgets", "Electronics", .) %>%
  gsub("Food & beverages", "Food", .) %>%
  # Simplify other common names
  gsub("Event tickets and entertainment services", "Entertainment", .) %>%
  gsub("Software and subscriptions", "Software", .) %>%
  gsub("Online courses and educations", "Online_Education", .) %>%
  gsub("Home appliances", "Home_Appliances", .) %>%
  gsub("Vehicles and accessories", "Vehicles", .) %>%
  gsub("Book and stationery", "Book", .) %>%
  # 2. Group rare values into 'Other'
  gsub("Toys|Laboratory items|Needs|None|Cat stuff|Envelopes for lucky money|Boardgame", 
       "Other", .)

table(raw_data5$Product_Category)

raw_data6 <- raw_data6 %>%
  dummy_cols(
    select_columns = "Product_Category",
    split = ',',
    remove_selected_columns = TRUE
  )






#handle special occasion

raw_data6$Special_Occasion

irrelevant_occasions <- c(
  "who shop only for special occasions\\? go to a real mall if it a special day",
  "Groceries",
  "When I have my salary"
)
# Create a single regex pattern for grouping
irrelevant_pattern_group <- paste0("(", paste(irrelevant_occasions, collapse = "|"), ")")


# Step 2: Apply Cleaning, Standardization, and Grouping to all rows
raw_data6$Special_Occasion <- raw_data6$Special_Occasion %>%
  gsub(irrelevant_pattern_group, "Other", .) %>%
  # B. Simplify core category names
  gsub("Tet Holiday \\(Lunar New Year\\)", "Tet_Holiday", .) %>%
  gsub("Black Friday", "Black_Holiday", .) %>%
  gsub("Back-To-School season", "Back-To-School_Season", .) %>%
  gsub("When gifts are needed", "Gift_Needed", .) %>%
  gsub("End-Of-Year clearance", "Year_End_Clearance", .) %>%
  gsub("I do not shop based on special occasions", "No_Special_Occasion_Shopping", .) %>%
  gsub("Holiday celebrations \\(Christmas, Mid-Autumn, etc.\\)", "Holiday_Celebrations", .) %>%
  gsub("Mega sale days \\(11\\.11, 12\\.12,\\.\\.\\)", "Mega_Sales", .) %>%
  gsub("Other,\\s*Other", "Other", .) %>% # Consolidate multiple 'Other' entries
  trimws(.) %>%
  gsub("^,+|,+$", "", .) # Remove leading/trailing commas


table(raw_data6$Special_Occasion)
raw_data6 <- raw_data6 %>%
  dummy_cols(
    select_columns = "Special_Occasion",
    split = ',',
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )

raw_data7<- copy(raw_data6)


#handle promotion type

CORE_PROMOTIONS_NAMES <- c("Percentage_Discount", "Bundle_Discount", "BOGO", 
                           "Flash_Sale", "Free_Shipping", "Voucher_Code")

# Step 1: Handle "Tất cả" (All) response
tất_cả_rows <- grepl("Tất cả", raw_data7$Promotion_Type, fixed = TRUE)

# For "Tất cả" rows, replace the cell content with ALL core simplified names
if (any(tất_cả_rows)) {
  ALL_PROMOTIONS_STRING <- paste(CORE_PROMOTIONS_NAMES, collapse = ", ")
  raw_data7$Promotion_Type[tất_cả_rows] <- ALL_PROMOTIONS_STRING
  cat(paste0("Handled ", sum(tất_cả_rows), " 'Tất cả' responses in Promotion_Type by setting all core promotions to TRUE.\n"))
}



raw_data7$Promotion_Type
irrelevant_promotions <- c(
  "Also depends on which products i'm gonna buy",
  "Tất cả"
)
irrelevant_promo_pattern_full <- paste0("(", paste(irrelevant_promotions, collapse = "|"), ")")

raw_data7$Promotion_Type <- raw_data7$Promotion_Type %>%
  # A. Remove irrelevant/comment categories
  gsub(irrelevant_promo_pattern_full, "", .) %>%
  gsub("Percentage discounts \\(e\\.g\\., 30%\\)", "Percentage_Discount", .) %>%
  gsub("Bundle discounts \\(combo sets\\)", "Bundle_Discount", .) %>%
  gsub("Buy 1 Get 1", "BOGO", .) %>%
  gsub("Flash sales", "Flash_Sale", .) %>%
  gsub("Free shipping", "Free_Shipping", .) %>%
  gsub("Voucher codes", "Voucher_Code", .) %>%
  gsub("I am not influenced by promotions", "No_Influence", .) %>%  
  trimws(.) %>%
  gsub("^,+|,+$", "", .) # Remove leading/trailing commas

raw_data7 <- raw_data7 %>%
  dummy_cols(
    select_columns = "Promotion_Type",
    split = ',',
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )
raw_data7$Promotion

#hanlde review action
raw_data7$Mixed_Review_Action

raw_data7 <- raw_data7 %>%
  mutate(
    Mixed_Review_Action = gsub("[…:()]+", "", Mixed_Review_Action),  # remove …, :, ( ) etc
    Mixed_Review_Action = trimws(Mixed_Review_Action)                 # trim whitespace
  )

# 1. Define irrelevant phrases
irrelevant_review_actions <- c(
  "Looking for bad review",
  "Check different platform's review on said product",
  "Tính toán, cân nhắc",
  "I still bought it because on these platforms ex Shoppe, Lazada,Tiki, if the product isn’t good, I can return it  so it doesn’t really affect my decision"
  
)


irrelevant_review_pattern <- paste0("(", paste(irrelevant_review_actions, collapse = "|"), ")")



# 4. Standardize remaining allowed core actions
raw_data7$Mixed_Review_Action <- raw_data7$Mixed_Review_Action%>%
  # 1. Group irrelevant/complex actions into 'Other'
  gsub(irrelevant_review_pattern, "Other", .) %>%
  # 2. Simplify core actions
  gsub("Read more reviews in detail to decide", "Read_More_Detail", .) %>%
  gsub("Look for alternative products", "Look_Alternative", .) %>%
  gsub("Still buy if the price is good", "Buy_If_Price_Good", .) %>%
  gsub("Avoid buying it", "Avoid_Buying", .) %>%
  gsub("It does not affect my decision", "No_Effect", .)%>%  
  gsub("Other,\\s*Other", "Other", .) %>% # Consolidate multiple 'Other' entries
  trimws(.) %>%
  gsub("^,+|,+$", "", .) # Remove leading/trailing commas



# 7. Dummy encode clean column
raw_data7 <- raw_data7 %>%
  dummy_cols(
    select_columns = "Mixed_Review_Action",
    split = ",",
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )



#handle column platform
raw_data8<- copy(raw_data7)
raw_data8$Main_Platform
Other_platforms <- c(
  "Amazon",
  "Tiki",
  "None",
  "Amazon, temu, shein,", # Captures the whole combined string
  "Grabfood",
  "Bách Hoá Xanh",
  "Thread",
  "The brand’s official website",
  "Không biết"
)

# Create a single regex pattern for the 'Other' group
Other_platforms_pattern <- paste0("(", paste(Other_platforms, collapse = "|"), ")")

# Step 2: Simplify and standardize core platforms
raw_data8$Main_Platform <- raw_data8$Main_Platform %>%
  # 1. Group irrelevant/complex platforms into 'Other'
  gsub(Other_platforms_pattern, "Other", .) %>%
  # 2. Simplify core platforms
  gsub("TikTok Shop", "TikTok_Shop", .) %>%
  gsub("Facebook Marketplace", "Facebook_Market", .) %>%
  gsub("Instagram Shop", "Instagram_Shop", .) %>%  
  gsub("Other,\\s*Other", "Other", .) %>% # Consolidate multiple 'Other' entries
  trimws(.) %>%
  gsub("^,+|,+$", "", .) # Remove leading/trailing commas

raw_data8 <- raw_data8 %>%
  dummy_cols(
    select_columns = "Main_Platform",
    split = ",",
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )

#handle market ting chanel
rm(raw_data9)
raw_data9<-copy(raw_data8)
table(raw_data9$Marketing_Channel)

irrelevant_marketing <- c(
  "Buy products when needed",
  "Depend",
  "I want something, I look for review videos, recommendations then buy",
  "N/A \\(I buy because I need to\\)",
  "non",
  "None",
  "none, i buy because i need it",
  "Not one",
  "On need",
  "The popularity of the company that issues the product matters\\.",
  "Follow links from the manufacturers",
  "Family and friends reference",
  "I don't buy things that people advertise agressively",
  "Othere",
  "Nhu cầu",
  "Nothing for now",
  "i buy because i need it",
  "I buy what i need\\.",
  "Youtube review that I trust"
)

# Create a single regex pattern for the 'Other' group
irrelevant_marketing_pattern <- paste(irrelevant_marketing, collapse = "|")


# Step 2: Simplify and standardize core channels
raw_data9$Marketing_Channel <- raw_data9$Marketing_Channel %>%
  # 1. Group irrelevant/complex actions into 'Other'
  gsub(irrelevant_marketing_pattern, "Other", .) %>%
  # 2. Simplify core channels
  gsub("Short videos \\(TikTok, Reels, Shorts\\)", "Short_Videos", .) %>%
  gsub("Social media posts \\(Facebook, Instagram, TikTok\\)", "Social_Media_Posts", .) %>%
  gsub("KOL/Influencer reviews", "Influencer_Reviews", .) %>%
  gsub("Ads on social media", "Social_Media_Ads", .) %>%
  gsub("Blogs/articles", "Blogs", .) %>%
  gsub("Livestream shopping", "Livestream", .) %>%  
  gsub("Other,\\s*Other", "Other", .) %>% # Consolidate multiple 'Other' entries
  trimws(.) %>%
  gsub("^,+|,+$", "", .) # Remove leading/trailing commas
raw_data9 <- raw_data9 %>%
  dummy_cols(
    select_columns = "Marketing_Channel",
    split = ",",
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )
raw_data9$Marketing_Channel
raw_data9 <- subset(raw_data9, select = -Marketing_Channel_Othere)


Final_dataset <- copy(raw_data9)
Final_dataset$Frustration_Issues

#handle frucstration issue

Frustration_Issues_NAMES <- c("Long_Delivery", "Poor_Quality", "Expectations_Mismatch", 
                           "Hidden_Fees", "Complicated_Returns")

tất_cả_rows <- grepl("Tất cả", Final_dataset$Frustration_Issues, fixed = TRUE)

if (any(tất_cả_rows)) {
  ALL_PROMOTIONS_STRING <- paste(Frustration_Issues_NAMES, collapse = ", ")
  Final_dataset$Frustration_Issues[tất_cả_rows] <- ALL_PROMOTIONS_STRING
  cat(paste0("Handled ", sum(tất_cả_rows), " 'Tất cả' responses in Promotion_Type by setting all core promotions to TRUE.\n"))
}


irrelevant_frustrations <- c(
  "NgocVuDepTraiDaTraLoi",
  "So fuking damnnn"
)



# Create a single regex pattern for the 'Other' group
irrelevant_frustrations_pattern <- paste(irrelevant_frustrations, collapse = "|")

# Step 2: Simplify and standardize core frustrations
Final_dataset$Frustration_Issues <- Final_dataset$Frustration_Issues %>%
  #  REMOVE irrelevant/complex actions entirely (replace with empty string)
  gsub(irrelevant_frustrations_pattern, "", .) %>%
  # 2. Simplify core frustrations
  gsub("Long delivery time", "Long_Delivery", .) %>%
  gsub("Poor product quality", "Poor_Quality", .) %>%
  gsub("Product does not meet your expectations", "Expectations_Mismatch", .) %>%
  gsub("Hidden fees / unexpected shipping costs", "Hidden_Fees", .) %>%
  gsub("Complicated return/refund process", "Complicated_Returns", .) %>%
  # 3. Clean up resulting empty strings/commas
  trimws(.) %>%
  gsub("^,+|,+$", "", .) %>%
  { .[nchar(.) == 0] <- NA_character_; . } # Replace empty strings with NA

Final_dataset <- Final_dataset %>%
  dummy_cols(
    select_columns = "Frustration_Issues",
    split = ",",
    remove_selected_columns = TRUE,
    remove_first_dummy = FALSE
  )

Final_dataset$f

library(readr)
write.csv(Final_dataset, file = "FinalDataset.csv", row.names = FALSE)
write.csv(Final_dataset, file = "C:/Users/LENOVO/OneDrive/Desktop/EC1/FinalDataset3.csv", row.names = FALSE)
