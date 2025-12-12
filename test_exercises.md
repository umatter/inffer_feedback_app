# R Code Feedback App - Manual Testing Exercises

Use these exercises and sample student responses to test the feedback quality across different skill levels.

---

## Exercise 1: Data Import

**Task:** Load the CSV file "sales_data.csv" and display the first 6 rows.

### Response A: Very Poor
```r
sales_data.csv
head
```

### Response B: Poor
```r
data = read.csv(sales_data.csv)
head(data)
```

### Response C: Good
```r
data <- read.csv("sales_data.csv")
head(data)
```

### Response D: Excellent
```r
# Load sales data from CSV file
sales_data <- read.csv("sales_data.csv", stringsAsFactors = FALSE)

# Display first 6 rows to verify import
head(sales_data)
```

---

## Exercise 2: Descriptive Statistics

**Task:** Calculate the mean, median, and standard deviation of a numeric vector called `prices`.

### Response A: Very Poor
```r
mean prices
median prices
sd prices
```

### Response B: Poor
```r
mean(prices)
median(prices)
sd(prices)
```

### Response C: Good
```r
# Calculate descriptive statistics
mean(prices, na.rm = TRUE)
median(prices, na.rm = TRUE)
sd(prices, na.rm = TRUE)
```

### Response D: Excellent
```r
# Calculate descriptive statistics for prices
# Using na.rm = TRUE to handle any missing values

price_mean <- mean(prices, na.rm = TRUE)
price_median <- median(prices, na.rm = TRUE)
price_sd <- sd(prices, na.rm = TRUE)

# Display results
cat("Mean:", price_mean, "\n")
cat("Median:", price_median, "\n")
cat("Standard Deviation:", price_sd, "\n")
```

---

## Exercise 3: Data Manipulation

**Task:** Using the `mtcars` dataset, filter cars with mpg greater than 20 and select only the columns `mpg`, `cyl`, and `hp`.

### Response A: Very Poor
```r
mtcars mpg > 20
```

### Response B: Poor
```r
library(dplyr)
filter(mtcars, mpg > 20)
select(mpg, cyl, hp)
```

### Response C: Good
```r
library(dplyr)
mtcars %>%
  filter(mpg > 20) %>%
  select(mpg, cyl, hp)
```

### Response D: Excellent
```r
# Load dplyr for data manipulation
library(dplyr)

# Filter efficient cars (mpg > 20) and select relevant columns
efficient_cars <- mtcars %>%
  filter(mpg > 20) %>%
  select(mpg, cyl, hp)

# Display result
efficient_cars
```

---

## Exercise 4: Data Visualization

**Task:** Create a histogram of the `Sepal.Length` variable from the `iris` dataset with appropriate labels.

### Response A: Very Poor
```r
histogram iris Sepal.Length
```

### Response B: Poor
```r
hist(iris$Sepal.Length)
```

### Response C: Good
```r
hist(iris$Sepal.Length,
     main = "Sepal Length Distribution",
     xlab = "Sepal Length")
```

### Response D: Excellent
```r
# Create histogram of Sepal Length from iris dataset
hist(iris$Sepal.Length,
     main = "Distribution of Sepal Length in Iris Dataset",
     xlab = "Sepal Length (cm)",
     ylab = "Frequency",
     col = "steelblue",
     border = "white",
     breaks = 15)

# Add a vertical line for the mean
abline(v = mean(iris$Sepal.Length), col = "red", lwd = 2, lty = 2)
```

---

## Exercise 5: Statistical Analysis

**Task:** Perform a correlation analysis between `Sepal.Length` and `Petal.Length` in the iris dataset.

### Response A: Very Poor
```r
correlation sepal petal
```

### Response B: Poor
```r
cor(Sepal.Length, Petal.Length)
```

### Response C: Good
```r
cor(iris$Sepal.Length, iris$Petal.Length)
```

### Response D: Excellent
```r
# Calculate Pearson correlation between Sepal.Length and Petal.Length
correlation <- cor(iris$Sepal.Length, iris$Petal.Length,
                   method = "pearson")

# Display correlation coefficient
cat("Correlation coefficient:", round(correlation, 3), "\n")

# Perform correlation test for significance
cor_test <- cor.test(iris$Sepal.Length, iris$Petal.Length)
print(cor_test)

# Visualize the relationship
plot(iris$Sepal.Length, iris$Petal.Length,
     xlab = "Sepal Length (cm)",
     ylab = "Petal Length (cm)",
     main = "Sepal vs Petal Length")
abline(lm(iris$Petal.Length ~ iris$Sepal.Length), col = "red")
```

---

## Exercise 6: Data Cleaning

**Task:** Check for missing values in a dataframe called `survey_data` and remove rows with any NA values.

### Response A: Very Poor
```r
remove NA survey_data
```

### Response B: Poor
```r
na.omit(survey_data)
```

### Response C: Good
```r
# Check for missing values
sum(is.na(survey_data))

# Remove rows with NA
clean_data <- na.omit(survey_data)
```

### Response D: Excellent
```r
# Check for missing values in each column
cat("Missing values per column:\n")
colSums(is.na(survey_data))

# Total missing values
cat("\nTotal missing values:", sum(is.na(survey_data)), "\n")

# Show percentage of complete cases
complete_pct <- mean(complete.cases(survey_data)) * 100
cat("Complete cases:", round(complete_pct, 1), "%\n")

# Remove rows with any NA values
clean_data <- na.omit(survey_data)

# Verify cleaning
cat("\nRows before:", nrow(survey_data), "\n")
cat("Rows after:", nrow(clean_data), "\n")
```

---

## Exercise 7: Creating a Scatterplot

**Task:** Create a scatterplot showing the relationship between `wt` (weight) and `mpg` (miles per gallon) from the mtcars dataset.

### Response A: Very Poor
```r
scatterplot mtcars wt mpg
```

### Response B: Poor
```r
plot(mtcars$wt, mtcars$mpg)
```

### Response C: Good
```r
plot(mtcars$wt, mtcars$mpg,
     xlab = "Weight",
     ylab = "MPG",
     main = "Weight vs MPG")
```

### Response D: Excellent
```r
# Scatterplot: Weight vs Fuel Efficiency
plot(mtcars$wt, mtcars$mpg,
     xlab = "Weight (1000 lbs)",
     ylab = "Miles per Gallon",
     main = "Car Weight vs Fuel Efficiency",
     pch = 19,
     col = "darkblue")

# Add regression line to show trend
model <- lm(mpg ~ wt, data = mtcars)
abline(model, col = "red", lwd = 2)

# Add legend
legend("topright",
       legend = c("Data points", "Trend line"),
       col = c("darkblue", "red"),
       pch = c(19, NA),
       lty = c(NA, 1))
```

---

## Exercise 8: Working with Factors

**Task:** Convert the `cyl` column in mtcars to a factor and create a boxplot of `mpg` grouped by `cyl`.

### Response A: Very Poor
```r
factor cyl
boxplot mpg cyl
```

### Response B: Poor
```r
mtcars$cyl <- factor(mtcars$cyl)
boxplot(mpg ~ cyl)
```

### Response C: Good
```r
mtcars$cyl <- factor(mtcars$cyl)
boxplot(mpg ~ cyl, data = mtcars,
        xlab = "Cylinders",
        ylab = "MPG")
```

### Response D: Excellent
```r
# Convert cylinders to factor with meaningful labels
mtcars$cyl_factor <- factor(mtcars$cyl,
                            levels = c(4, 6, 8),
                            labels = c("4 Cylinders", "6 Cylinders", "8 Cylinders"))

# Create boxplot comparing MPG across cylinder groups
boxplot(mpg ~ cyl_factor, data = mtcars,
        main = "Fuel Efficiency by Number of Cylinders",
        xlab = "Engine Type",
        ylab = "Miles per Gallon",
        col = c("lightgreen", "lightyellow", "lightcoral"),
        border = "darkgray")

# Add mean points
means <- tapply(mtcars$mpg, mtcars$cyl_factor, mean)
points(1:3, means, pch = 18, col = "darkred", cex = 1.5)
```

---

## Exercise 9: Calculating Skewness

**Task:** Calculate and interpret the skewness of the `Sepal.Width` variable from the iris dataset. Determine if the distribution is left-skewed, right-skewed, or approximately symmetric.

### Response A: Very Poor
```r
skewness iris Sepal.Width
```

### Response B: Poor
```r
library(moments)
skewness(iris$Sepal.Width)
```

### Response C: Good
```r
library(moments)

# Calculate skewness
skew <- skewness(iris$Sepal.Width)
cat("Skewness:", skew, "\n")

# Basic interpretation
if (skew > 0) {
  cat("Right-skewed distribution\n")
} else if (skew < 0) {
  cat("Left-skewed distribution\n")
} else {
  cat("Symmetric distribution\n")
}
```

### Response D: Excellent
```r
# Load moments package for skewness calculation
library(moments)

# Calculate skewness of Sepal.Width
skew_value <- skewness(iris$Sepal.Width, na.rm = TRUE)

# Calculate kurtosis for additional distributional insight
kurt_value <- kurtosis(iris$Sepal.Width, na.rm = TRUE)

# Interpretation with thresholds
cat("=== Distribution Analysis: Sepal.Width ===\n\n")
cat("Skewness:", round(skew_value, 4), "\n")
cat("Kurtosis:", round(kurt_value, 4), "\n\n")

# Skewness interpretation (common thresholds: |skew| < 0.5 is approx symmetric)
if (abs(skew_value) < 0.5) {
  cat("Interpretation: Approximately symmetric distribution\n")
} else if (skew_value >= 0.5) {
  cat("Interpretation: Moderately to highly right-skewed (positive skew)\n")
  cat("  - Tail extends toward higher values\n")
  cat("  - Mean > Median typically\n")
} else {
  cat("Interpretation: Moderately to highly left-skewed (negative skew)\n")
  cat("  - Tail extends toward lower values\n")
  cat("  - Mean < Median typically\n")
}

# Visualize with histogram and density
par(mfrow = c(1, 2))
hist(iris$Sepal.Width, breaks = 15, probability = TRUE,
     main = "Histogram with Density", xlab = "Sepal Width (cm)",
     col = "lightblue", border = "white")
lines(density(iris$Sepal.Width), col = "red", lwd = 2)
abline(v = mean(iris$Sepal.Width), col = "blue", lty = 2, lwd = 2)
abline(v = median(iris$Sepal.Width), col = "green", lty = 2, lwd = 2)
legend("topright", legend = c("Density", "Mean", "Median"),
       col = c("red", "blue", "green"), lty = c(1, 2, 2), cex = 0.8)

# Q-Q plot for normality assessment
qqnorm(iris$Sepal.Width, main = "Q-Q Plot")
qqline(iris$Sepal.Width, col = "red", lwd = 2)
par(mfrow = c(1, 1))
```

---

## Exercise 10: Bootstrap Confidence Interval for the Mean

**Task:** Using the `mtcars` dataset, calculate a 95% bootstrap confidence interval for the mean of `mpg` using 10,000 bootstrap samples.

### Response A: Very Poor
```r
bootstrap mtcars mpg 95%
confidence interval mean
```

### Response B: Poor
```r
boot_means <- replicate(1000, mean(sample(mtcars$mpg)))
quantile(boot_means, c(0.025, 0.975))
```

### Response C: Good
```r
# Set seed for reproducibility
set.seed(123)

# Bootstrap resampling
n <- length(mtcars$mpg)
boot_means <- replicate(10000, {
  boot_sample <- sample(mtcars$mpg, n, replace = TRUE)
  mean(boot_sample)
})

# Calculate 95% CI using percentile method
ci <- quantile(boot_means, c(0.025, 0.975))
cat("95% Bootstrap CI for mean MPG:", ci[1], "-", ci[2], "\n")
```

### Response D: Excellent
```r
# Bootstrap Confidence Interval for Mean MPG
# Using 10,000 bootstrap replications

set.seed(42)  # For reproducibility

# Original data
mpg_data <- mtcars$mpg
n <- length(mpg_data)
original_mean <- mean(mpg_data)

# Number of bootstrap samples
B <- 10000

# Bootstrap resampling
boot_means <- replicate(B, {
  boot_sample <- sample(mpg_data, size = n, replace = TRUE)
  mean(boot_sample)
})

# Calculate confidence intervals using multiple methods
ci_percentile <- quantile(boot_means, probs = c(0.025, 0.975))

# Basic bootstrap CI (using bias correction)
bias <- mean(boot_means) - original_mean
ci_basic <- c(2 * original_mean - ci_percentile[2],
              2 * original_mean - ci_percentile[1])

# Bootstrap standard error
boot_se <- sd(boot_means)

# Normal approximation CI
ci_normal <- c(original_mean - 1.96 * boot_se,
               original_mean + 1.96 * boot_se)

# Report results
cat("=== Bootstrap Analysis: Mean MPG ===\n\n")
cat("Sample size:", n, "\n")
cat("Bootstrap replications:", B, "\n")
cat("Original sample mean:", round(original_mean, 3), "\n")
cat("Bootstrap SE:", round(boot_se, 3), "\n")
cat("Bootstrap bias:", round(bias, 4), "\n\n")

cat("95% Confidence Intervals:\n")
cat("  Percentile method:", round(ci_percentile[1], 3), "-",
    round(ci_percentile[2], 3), "\n")
cat("  Basic method:     ", round(ci_basic[1], 3), "-",
    round(ci_basic[2], 3), "\n")
cat("  Normal approx:    ", round(ci_normal[1], 3), "-",
    round(ci_normal[2], 3), "\n")

# Visualize bootstrap distribution
hist(boot_means, breaks = 50, probability = TRUE,
     main = "Bootstrap Distribution of Mean MPG",
     xlab = "Bootstrap Mean", col = "lightblue", border = "white")
abline(v = original_mean, col = "red", lwd = 2, lty = 1)
abline(v = ci_percentile, col = "darkgreen", lwd = 2, lty = 2)
legend("topright",
       legend = c("Original Mean", "95% CI"),
       col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2)
```

---

## Exercise 11: Bootstrap Test for Difference in Means

**Task:** Using the iris dataset, perform a bootstrap hypothesis test to determine if there is a significant difference in mean `Petal.Length` between the "setosa" and "versicolor" species. Use 10,000 bootstrap samples.

### Response A: Very Poor
```r
bootstrap test setosa versicolor petal length
difference means
```

### Response B: Poor
```r
setosa <- iris$Petal.Length[iris$Species == "setosa"]
versicolor <- iris$Petal.Length[iris$Species == "versicolor"]
mean(setosa) - mean(versicolor)
```

### Response C: Good
```r
# Extract data for each species
setosa <- iris$Petal.Length[iris$Species == "setosa"]
versicolor <- iris$Petal.Length[iris$Species == "versicolor"]

# Observed difference
obs_diff <- mean(setosa) - mean(versicolor)

# Bootstrap under null hypothesis (pooled data)
set.seed(123)
pooled <- c(setosa, versicolor)
n1 <- length(setosa)
n2 <- length(versicolor)

boot_diffs <- replicate(10000, {
  shuffled <- sample(pooled)
  mean(shuffled[1:n1]) - mean(shuffled[(n1+1):(n1+n2)])
})

# Calculate p-value (two-sided)
p_value <- mean(abs(boot_diffs) >= abs(obs_diff))
cat("Observed difference:", obs_diff, "\n")
cat("Bootstrap p-value:", p_value, "\n")
```

### Response D: Excellent
```r
# Bootstrap Hypothesis Test: Difference in Mean Petal Length
# H0: No difference between setosa and versicolor
# H1: There is a difference (two-sided test)

set.seed(2024)

# Extract petal lengths by species
setosa_petal <- iris$Petal.Length[iris$Species == "setosa"]
versicolor_petal <- iris$Petal.Length[iris$Species == "versicolor"]

n_setosa <- length(setosa_petal)
n_versicolor <- length(versicolor_petal)

# Observed test statistic (difference in means)
obs_diff <- mean(setosa_petal) - mean(versicolor_petal)

# Descriptive statistics
cat("=== Descriptive Statistics ===\n")
cat("Setosa:     n =", n_setosa, ", mean =", round(mean(setosa_petal), 3),
    ", sd =", round(sd(setosa_petal), 3), "\n")
cat("Versicolor: n =", n_versicolor, ", mean =", round(mean(versicolor_petal), 3),
    ", sd =", round(sd(versicolor_petal), 3), "\n")
cat("Observed difference (setosa - versicolor):", round(obs_diff, 3), "\n\n")

# Bootstrap permutation test under H0
# Under null, species labels are exchangeable
pooled_data <- c(setosa_petal, versicolor_petal)
B <- 10000

boot_diffs <- replicate(B, {
  # Permute the pooled data
  permuted <- sample(pooled_data)
  # Calculate difference in means under permutation
  mean(permuted[1:n_setosa]) - mean(permuted[(n_setosa + 1):(n_setosa + n_versicolor)])
})

# Calculate p-value (two-sided)
p_value_two_sided <- mean(abs(boot_diffs) >= abs(obs_diff))

# Also calculate bootstrap CI for the difference (non-null bootstrap)
boot_diff_ci <- replicate(B, {
  boot_setosa <- sample(setosa_petal, n_setosa, replace = TRUE)
  boot_versicolor <- sample(versicolor_petal, n_versicolor, replace = TRUE)
  mean(boot_setosa) - mean(boot_versicolor)
})

ci_95 <- quantile(boot_diff_ci, c(0.025, 0.975))

# Report results
cat("=== Bootstrap Hypothesis Test Results ===\n")
cat("Number of bootstrap samples:", B, "\n")
cat("Two-sided p-value:", format(p_value_two_sided, scientific = FALSE), "\n\n")

cat("=== 95% Bootstrap CI for Difference ===\n")
cat("CI:", round(ci_95[1], 3), "to", round(ci_95[2], 3), "\n\n")

# Interpretation
alpha <- 0.05
cat("=== Interpretation (α =", alpha, ") ===\n")
if (p_value_two_sided < alpha) {
  cat("Reject H0: Significant difference in mean petal length\n")
  cat("between setosa and versicolor species.\n")
} else {
  cat("Fail to reject H0: No significant difference detected.\n")
}

# Effect size (Cohen's d)
pooled_sd <- sqrt(((n_setosa - 1) * var(setosa_petal) +
                    (n_versicolor - 1) * var(versicolor_petal)) /
                   (n_setosa + n_versicolor - 2))
cohens_d <- obs_diff / pooled_sd
cat("Cohen's d:", round(cohens_d, 3), "(effect size)\n")

# Visualization
par(mfrow = c(1, 2))

# Permutation distribution
hist(boot_diffs, breaks = 50, probability = TRUE,
     main = "Permutation Distribution\n(under H0)",
     xlab = "Difference in Means", col = "lightgray", border = "white")
abline(v = obs_diff, col = "red", lwd = 3)
abline(v = -obs_diff, col = "red", lwd = 3, lty = 2)
legend("topright", legend = c("Observed diff", "Mirror"),
       col = "red", lty = c(1, 2), lwd = 2, cex = 0.8)

# Bootstrap CI distribution
hist(boot_diff_ci, breaks = 50, probability = TRUE,
     main = "Bootstrap Distribution\nof Difference",
     xlab = "Difference in Means", col = "lightblue", border = "white")
abline(v = ci_95, col = "darkgreen", lwd = 2, lty = 2)
abline(v = obs_diff, col = "red", lwd = 2)
legend("topright", legend = c("Observed", "95% CI"),
       col = c("red", "darkgreen"), lty = c(1, 2), lwd = 2, cex = 0.8)

par(mfrow = c(1, 1))
```

---

## Exercise 12: Confidence Interval for Proportion

**Task:** In a survey of 500 customers, 320 said they would recommend the product. Calculate a 95% confidence interval for the true proportion of customers who would recommend the product using both the normal approximation and exact (Clopper-Pearson) methods.

### Response A: Very Poor
```r
confidence interval 320/500 proportion
95% CI recommend
```

### Response B: Poor
```r
prop.test(320, 500)
```

### Response C: Good
```r
# Sample data
successes <- 320
n <- 500
p_hat <- successes / n

# Normal approximation CI
se <- sqrt(p_hat * (1 - p_hat) / n)
ci_normal <- c(p_hat - 1.96 * se, p_hat + 1.96 * se)

cat("Sample proportion:", p_hat, "\n")
cat("95% CI (normal):", ci_normal[1], "-", ci_normal[2], "\n")

# Using prop.test for comparison
prop.test(successes, n, conf.level = 0.95)
```

### Response D: Excellent
```r
# Confidence Interval for Proportion
# Survey: 320 out of 500 customers recommend the product

successes <- 320
n <- 500
p_hat <- successes / n
q_hat <- 1 - p_hat

cat("=== Sample Statistics ===\n")
cat("Sample size (n):", n, "\n")
cat("Successes (x):", successes, "\n")
cat("Sample proportion (p̂):", round(p_hat, 4), "\n\n")

# Check if normal approximation is appropriate
# Rule of thumb: np >= 10 and n(1-p) >= 10
cat("=== Validity Check for Normal Approximation ===\n")
cat("n * p̂ =", n * p_hat, "(should be >= 10)\n")
cat("n * (1-p̂) =", n * q_hat, "(should be >= 10)\n")
cat("Normal approximation:", ifelse(n * p_hat >= 10 & n * q_hat >= 10,
                                     "VALID", "USE EXACT METHOD"), "\n\n")

# Method 1: Wald (Normal approximation) interval
se_wald <- sqrt(p_hat * q_hat / n)
z_crit <- qnorm(0.975)
ci_wald <- c(p_hat - z_crit * se_wald, p_hat + z_crit * se_wald)

# Method 2: Wilson score interval (better coverage properties)
wilson_result <- prop.test(successes, n, conf.level = 0.95, correct = FALSE)
ci_wilson <- wilson_result$conf.int

# Method 3: Clopper-Pearson exact interval
ci_exact <- binom.test(successes, n, conf.level = 0.95)$conf.int

# Method 4: Agresti-Coull interval
n_tilde <- n + z_crit^2
p_tilde <- (successes + z_crit^2 / 2) / n_tilde
se_ac <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)
ci_agresti <- c(p_tilde - z_crit * se_ac, p_tilde + z_crit * se_ac)

# Report all intervals
cat("=== 95% Confidence Intervals ===\n\n")
cat("Method              Lower    Upper    Width\n")
cat("-----------------------------------------------\n")
cat(sprintf("Wald (Normal):      %.4f   %.4f   %.4f\n",
            ci_wald[1], ci_wald[2], diff(ci_wald)))
cat(sprintf("Wilson Score:       %.4f   %.4f   %.4f\n",
            ci_wilson[1], ci_wilson[2], diff(ci_wilson)))
cat(sprintf("Clopper-Pearson:    %.4f   %.4f   %.4f\n",
            ci_exact[1], ci_exact[2], diff(ci_exact)))
cat(sprintf("Agresti-Coull:      %.4f   %.4f   %.4f\n",
            ci_agresti[1], ci_agresti[2], diff(ci_agresti)))

cat("\n=== Interpretation ===\n")
cat("We are 95% confident that the true proportion of customers\n")
cat("who would recommend the product is between",
    round(ci_wilson[1] * 100, 1), "% and",
    round(ci_wilson[2] * 100, 1), "%.\n")

# Visualization
proportions <- c(p_hat, p_hat, p_hat, p_hat)
lower <- c(ci_wald[1], ci_wilson[1], ci_exact[1], ci_agresti[1])
upper <- c(ci_wald[2], ci_wilson[2], ci_exact[2], ci_agresti[2])
methods <- c("Wald", "Wilson", "Clopper-Pearson", "Agresti-Coull")

# Plot confidence intervals
par(mar = c(5, 12, 4, 2))
plot(NULL, xlim = c(0.58, 0.70), ylim = c(0.5, 4.5),
     xlab = "Proportion", ylab = "", yaxt = "n",
     main = "95% Confidence Intervals for Proportion")
axis(2, at = 1:4, labels = methods, las = 1)
abline(v = p_hat, col = "red", lty = 2, lwd = 2)

for (i in 1:4) {
  segments(lower[i], i, upper[i], i, lwd = 3, col = "darkblue")
  points(c(lower[i], upper[i]), c(i, i), pch = "|", cex = 1.5, col = "darkblue")
  points(proportions[i], i, pch = 19, col = "red", cex = 1.2)
}
legend("topright", legend = c("Point estimate", "95% CI"),
       col = c("red", "darkblue"), pch = c(19, NA), lty = c(NA, 1), lwd = 2)
par(mar = c(5, 4, 4, 2))
```

---

## Exercise 13: Assessing Normality with Skewness and Kurtosis

**Task:** Generate a sample of 200 observations from an exponential distribution with rate = 0.5. Calculate the skewness and kurtosis, and assess how the distribution deviates from normality.

### Response A: Very Poor
```r
exponential sample 200 rate 0.5
skewness kurtosis normality
```

### Response B: Poor
```r
set.seed(1)
x <- rexp(200, rate = 0.5)
library(moments)
skewness(x)
kurtosis(x)
```

### Response C: Good
```r
library(moments)

# Generate exponential sample
set.seed(42)
exp_sample <- rexp(200, rate = 0.5)

# Calculate moments
skew <- skewness(exp_sample)
kurt <- kurtosis(exp_sample)

cat("Skewness:", round(skew, 3), "\n")
cat("Kurtosis:", round(kurt, 3), "\n")

# For reference: normal distribution has skewness=0, kurtosis=3
cat("\nDeviation from normal:\n")
cat("Skewness deviation:", round(skew - 0, 3), "\n")
cat("Excess kurtosis:", round(kurt - 3, 3), "\n")

# Visual check
hist(exp_sample, breaks = 20, probability = TRUE, main = "Exponential Sample")
curve(dexp(x, rate = 0.5), add = TRUE, col = "red", lwd = 2)
```

### Response D: Excellent
```r
# Normality Assessment Using Skewness and Kurtosis
# Sample: 200 observations from Exponential(rate = 0.5)

library(moments)

set.seed(2024)

# Generate sample
n <- 200
rate <- 0.5
exp_sample <- rexp(n, rate = rate)

# Theoretical values for Exp(rate) distribution
# Mean = 1/rate, Variance = 1/rate^2
# Skewness = 2 (always for exponential)
# Kurtosis = 9 (excess kurtosis = 6)
theo_mean <- 1 / rate
theo_var <- 1 / rate^2
theo_skew <- 2
theo_kurt <- 9  # (excess = 6)

# Sample statistics
sample_mean <- mean(exp_sample)
sample_var <- var(exp_sample)
sample_skew <- skewness(exp_sample)
sample_kurt <- kurtosis(exp_sample)  # moments package returns regular kurtosis

# Standard errors for skewness and kurtosis (under normality assumption)
se_skew <- sqrt(6 / n)
se_kurt <- sqrt(24 / n)

# Z-tests for normality
z_skew <- sample_skew / se_skew
z_kurt <- (sample_kurt - 3) / se_kurt  # test against normal kurtosis = 3

# Jarque-Bera test for normality
jb_test <- jarque.test(exp_sample)

cat("=== Sample Generation ===\n")
cat("Distribution: Exponential(rate =", rate, ")\n")
cat("Sample size:", n, "\n\n")

cat("=== Descriptive Statistics ===\n")
cat(sprintf("%-20s %10s %10s\n", "Statistic", "Sample", "Theoretical"))
cat(sprintf("%-20s %10.3f %10.3f\n", "Mean", sample_mean, theo_mean))
cat(sprintf("%-20s %10.3f %10.3f\n", "Variance", sample_var, theo_var))
cat(sprintf("%-20s %10.3f %10.3f\n", "Skewness", sample_skew, theo_skew))
cat(sprintf("%-20s %10.3f %10.3f\n", "Kurtosis", sample_kurt, theo_kurt))

cat("\n=== Normality Assessment ===\n")
cat("Reference: Normal distribution has skewness = 0, kurtosis = 3\n\n")

cat("Skewness test:\n")
cat("  Sample skewness:", round(sample_skew, 3), "\n")
cat("  SE (under H0):", round(se_skew, 3), "\n")
cat("  Z-statistic:", round(z_skew, 3), "\n")
cat("  Conclusion:", ifelse(abs(z_skew) > 1.96,
                            "REJECT normality (p < 0.05)",
                            "Do not reject normality"), "\n\n")

cat("Kurtosis test:\n")
cat("  Sample kurtosis:", round(sample_kurt, 3), "\n")
cat("  Excess kurtosis:", round(sample_kurt - 3, 3), "\n")
cat("  SE (under H0):", round(se_kurt, 3), "\n")
cat("  Z-statistic:", round(z_kurt, 3), "\n")
cat("  Conclusion:", ifelse(abs(z_kurt) > 1.96,
                            "REJECT normality (p < 0.05)",
                            "Do not reject normality"), "\n\n")

cat("Jarque-Bera test:\n")
cat("  Test statistic:", round(jb_test$statistic, 3), "\n")
cat("  P-value:", format(jb_test$p.value, digits = 4), "\n")
cat("  Conclusion:", ifelse(jb_test$p.value < 0.05,
                            "REJECT normality",
                            "Do not reject normality"), "\n")

cat("\n=== Interpretation ===\n")
cat("The exponential distribution is:\n")
cat("  - Right-skewed (positive skewness = 2)\n")
cat("  - Leptokurtic (heavy-tailed, kurtosis > 3)\n")
cat("These characteristics make it clearly non-normal.\n")

# Comprehensive visualization
par(mfrow = c(2, 2))

# 1. Histogram with theoretical densities
hist(exp_sample, breaks = 25, probability = TRUE,
     main = "Histogram with Density Curves",
     xlab = "Value", col = "lightblue", border = "white")
curve(dexp(x, rate = rate), add = TRUE, col = "red", lwd = 2)
curve(dnorm(x, mean = sample_mean, sd = sqrt(sample_var)),
      add = TRUE, col = "blue", lwd = 2, lty = 2)
legend("topright", legend = c("Exponential", "Normal fit"),
       col = c("red", "blue"), lty = c(1, 2), lwd = 2, cex = 0.8)

# 2. Q-Q plot against normal
qqnorm(exp_sample, main = "Q-Q Plot (vs Normal)", pch = 20, col = "darkblue")
qqline(exp_sample, col = "red", lwd = 2)

# 3. Q-Q plot against exponential
exp_theoretical <- qexp(ppoints(n), rate = rate)
plot(sort(exp_theoretical), sort(exp_sample),
     main = "Q-Q Plot (vs Exponential)",
     xlab = "Theoretical Quantiles", ylab = "Sample Quantiles",
     pch = 20, col = "darkgreen")
abline(0, 1, col = "red", lwd = 2)

# 4. Boxplot with reference
boxplot(exp_sample, horizontal = TRUE,
        main = "Boxplot of Sample",
        xlab = "Value", col = "lightyellow")
points(sample_mean, 1, pch = 18, col = "red", cex = 2)
legend("topright", legend = "Mean", pch = 18, col = "red", cex = 0.8)

par(mfrow = c(1, 1))
```

---

## Testing Notes

When testing with these responses, verify that the app:

1. **Very Poor responses**: Identifies syntax errors and provides basic guidance
2. **Poor responses**: Points out missing elements (quotes, proper function calls, etc.)
3. **Good responses**: Acknowledges correctness while suggesting improvements
4. **Excellent responses**: Praises best practices (comments, meaningful variable names, visualization enhancements)

### Expected Feedback Elements

| Response Level | Expected Feedback |
|----------------|-------------------|
| Very Poor | Syntax errors, basic R syntax guidance |
| Poor | Missing quotes, incomplete code, basic corrections |
| Good | Works correctly, suggest enhancements (comments, na.rm, labels) |
| Excellent | Praise for best practices, maybe minor style suggestions |

### Advanced Exercises (9-13) Notes

The advanced exercises cover statistical inference topics requiring deeper understanding:

| Exercise | Topic | Key Concepts to Check |
|----------|-------|----------------------|
| 9 | Skewness | Interpretation thresholds, library usage (`moments`), visualization |
| 10 | Bootstrap CI | Resampling with replacement, percentile method, `set.seed()` |
| 11 | Bootstrap Difference | Permutation test, pooled data, p-value calculation, effect size |
| 12 | Proportion CI | Normal approx validity, multiple methods (Wald, Wilson, exact) |
| 13 | Normality Testing | Jarque-Bera test, Q-Q plots, skewness/kurtosis interpretation |

**For advanced exercises, the AI should:**
- Recognize when `library(moments)` is needed but missing
- Check for reproducibility (`set.seed()`)
- Validate bootstrap sample size (should be large, e.g., 10000)
- Comment on statistical interpretation, not just code mechanics
- Suggest visualizations when appropriate
