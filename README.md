# 📊Data Analysis in High Dimensions (R Project)

## 📈Overview
This project applies a dimension-reduction–based clustering workflow to segment Vietnamese e-commerce consumers using mixed survey data. Instead of clustering directly on raw variables, I first transforms categorical and numerical features into a unified continuous space using MCA and PCA, then performs hierarchical clustering on the reduced components.
This approach is designed to:
- Handle high-dimensional survey data
- Reduce noise and multicollinearity
- Improve cluster stability and interpretability

# 📌Step-by-Step Methodology

## 📌Data Preparation
The data was collected using a structured online questionnaire designed and distributed through Google Forms. The survey targeted university students and working professionals in Vietnam and was shared via social media platforms and academic networks to ensure efficient reach.

All responses were automatically recorded in a tabular format, allowing seamless export to CSV for further cleaning and analysis. This approach ensured standardized data collection, minimized manual entry errors, and provided a reliable foundation for subsequent preprocessing and clustering analysis.
##  📌Data Cleaning and Profiling Process

The raw survey data was cleaned and standardized to ensure reliability for clustering analysis. Column names were first simplified for consistency and ease of use. Numerical variables such as age and spending were recoded into representative midpoint values to reduce noise and improve interpretability. Binary variables (e.g., student status) were encoded into numeric form.

Categorical and ordinal responses, including shopping frequency, discount importance, and platform-switching likelihood, were standardized and transformed using numeric scaling or dummy encoding. Multi-choice and text-based responses were cleaned, rare values were grouped into an “Other” category, and one-hot encoding was applied.

After preprocessing, the dataset showed consistent variable formats, no invalid values, and a clean structure, making it fully ready for clustering and interpretation.

## 📌Apply Hierarchical Clustering
## Agglomerative Hierarchical Clustering Overview
To identify meaningful consumer segments without predefining the number of groups, this study employs agglomerative hierarchical clustering. This bottom-up approach starts by treating each respondent as an individual cluster and then progressively merges the most similar clusters step by step until a hierarchical structure is formed.
## Ward’s Linkage Method
Ward’s method is a linkage criterion used in agglomerative hierarchical clustering that focuses on forming compact and well-separated clusters. At each step of the clustering process, it merges the pair of clusters that results in the smallest increase in total within-cluster variance.

Unlike other linkage methods that rely only on the distance between points or cluster extremes, Ward’s method considers the overall cluster structure. This leads to clusters that are relatively balanced in size and more internally homogeneous, making them easier to interpret in a consumer segmentation context.
## Multiple Correspondence Analysis (MCA) and Principal Component Analysis (PCA)
- MCA is applied to categorical variables to convert qualitative responses into continuous latent dimensions making sure only the top components explaining the majority of inertia are retained and reduces hundreds of dummy variables into a compact feature space.
- PCA is applied to numerical and ordinal variables to normalize scale differences making sure principal components retain the maximum variance with minimal information loss and only significant components (based on explained variance) are selected.

**Why Use MCA + PCA?**

- Avoids bias from high-cardinality categorical variables
- Improves clustering performance in mixed-data scenarios
- Produces cleaner, more interpretable clusters

Particularly suitable for survey-based consumer segmentation
## 💡Clustering Results
After transforming the mixed survey data using MCA (categorical variables) and PCA (numerical variables), agglomerative hierarchical clustering (Ward’s method) was applied to the combined component space. This process identified four distinct consumer segments, primarily differentiated by age, spending level, review dependence, price sensitivity, and platform loyalty.

**Cluster 0** – High-spend, review-aware, not very loyal (Age ≈ 26)
Older, high-value shoppers who actively read reviews and evaluate quality, but show weak platform loyalty and are willing to switch when better value or trust signals appear.

**Cluster 1** – Occasional low-spend browsers (Age ≈ 26)
Older, low-frequency users with limited spending and engagement. They check reviews but shop infrequently and show moderate, passive platform loyalty.

**Cluster 2** – Young, low-spend, review-focused value seekers (Age ≈ 18)
Young, budget-constrained consumers who rely heavily on reviews, discounts, and comparisons before purchasing. Highly cautious and price-sensitive, with low spending and low shopping frequency.

**Cluster 3** – Young high-spend habitual shoppers (Age ≈ 18)
Young, high-spending consumers who purchase more out of habit or convenience. They show moderate review usage, lower comparison effort, and relatively stable platform usage.

Overall, the hierarchical clustering results demonstrate that consumer behavior and decision-making patterns are not driven by age or income alone, but by varying levels of caution, value perception, and loyalty, which are effectively captured through the MCA + PCA framework.

## 📄Conclusion
This project demonstrates the effectiveness of combining MCA, PCA, and agglomerative hierarchical clustering to segment high-dimensional, mixed-type survey data in the Vietnamese e-commerce context. The hierarchical clustering results reveal four distinct consumer segments with clear differences in spending behavior, review dependence, price sensitivity, and platform loyalty. Importantly, the findings show that consumer decision-making is shaped not only by age or spending power, but also by behavioral caution, value perception, and habitual purchasing patterns.

Overall, this dimension-reduction–based clustering framework provides a robust and scalable approach for consumer segmentation and offers practical insights for e-commerce platforms to tailor pricing strategies, trust signals, and engagement mechanisms to different customer groups.
