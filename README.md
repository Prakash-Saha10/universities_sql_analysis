# Universities Dataset SQL Analysis

This project contains a **comprehensive SQL analysis of global universities**. The dataset includes information about university names, founding years, geographic coordinates, and countries. The queries demonstrate how to clean, summarize, and analyze data from **basic to advanced analytical tasks**.

---

## 📊 Dataset Overview

| Column Name      | Description                                             |
|-----------------|---------------------------------------------------------|
| `university`     | Unique identifier or URL for the university            |
| `coord`          | Geographic coordinates in `Point(lat lon)` format      |
| `inception`      | Founding date of the university (YYYY-MM-DD)          |
| `universityLabel`| Name of the university                                  |
| `countryLabel`   | Country where the university is located                |

The data may contain missing or invalid values, which are handled in the queries.

---

## 📝 Project Summary

The analysis is structured into **three levels**:

### 1️⃣ Basic Queries
- View all universities and filter by country.  
- Count universities per country.  
- Find universities founded before 1900.  
- Order universities by founding year.  
- Search universities by name.  
- Identify universities with missing coordinates.  

### 2️⃣ Intermediate Queries
- Calculate **average founding year per country**.  
- Find **top 3 oldest universities per country**.  
- Count universities founded in a specific period (e.g., 1950–2000).  
- Categorize universities by **era**: Ancient, Modern, Contemporary.  
- Identify universities older than the country average.  
- Extract latitude and longitude from the `coord` column.  

### 3️⃣ Advanced / Analytical Queries
- Rank universities per country and globally.  
- Cumulative counts and percentile rankings.  
- Median founding year per country.  
- Pivot data to show counts per century.  
- Analyze countries where most universities are recently founded.  
- Correlation between latitude and founding year.  
- Calculate university age and categorize into historical eras.  
- Rank countries by **average university age**.  
- Composite score combining **age and latitude** for advanced analysis.  

---

## ⚡ Key Takeaways

- Data cleaning is essential for handling missing or malformed values.  
- SQL **window functions** (`ROW_NUMBER()`, `RANK()`, `NTILE()`) are powerful for ranking and percentile calculations.  
- Aggregations and pivot tables help summarize data by country and era.  
- Advanced queries allow analytical insights like **global trends, age distribution, and geographic correlations**.  

---


This project is suitable for **SQL learners** from beginner to advanced levels, and demonstrates real-world **analytical techniques** on a global dataset.
