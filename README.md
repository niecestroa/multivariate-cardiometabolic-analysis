# **Investigating Cardiovascular & Metabolic Health Using Multivariate Analysis**

## **Abstract**  
This project examines how age, gender, BMI, and hypertension status jointly influence key cardiovascular and metabolic indicators—pulse rate, systolic and diastolic blood pressure, and glucose levels. Using MANOVA, MANCOVA, Hotelling’s T² tests, and multivariate regression, the analysis evaluates both independent and combined effects of demographic and clinical predictors. Box‑Cox transformations were applied to improve normality, and model comparisons highlight hypertension status and BMI as especially strong contributors to variation in health outcomes. The study demonstrates the value of multivariate methods in understanding interconnected physiological processes.

---

## **Authors**  
- **Weiyi Huang**  
- **Aaron Niecestro**  
- **Yuzhou Pan**  
- **Alison Stephens**

---

## **Project Overview**  
This academic project was completed as part of **Applied Multivariate Data Analysis** at UTHealth Houston.  
- **Start:** February 2025  
- **Completion:** May 2025  
- **Purpose:** Explore multivariate relationships among cardiovascular and metabolic health indicators using real‑world clinical data.

---

## **Dataset**  
- Source: **Kaggle** (DiaHealth dataset)  
- Sample size: 5,437 adults  
- Variables: 14 predictors including demographics, vitals, and medical history  
- Preprocessing included physiologically reasonable filtering for BMI, blood pressure, glucose, and pulse rate.

---

## **Methods Used**  
- Box‑Cox transformations  
- Hotelling’s T² tests  
- One‑way and two‑way MANOVA  
- MANCOVA with age as covariate  
- Multivariate linear regression with nested model comparison (AIC + LRT)

---

## **Key Findings**  
- BMI, hypertension status, gender, and age significantly predict cardiovascular and metabolic outcomes.  
- Hypertension status strongly influences both systolic and diastolic blood pressure.  
- BMI categories show clear differences in blood pressure and glucose.  
- Gender differences are most pronounced in pulse rate.  
- Age acts as a confounder and must be controlled for in multivariate models.

---

## **Limitations**  
- Cross‑sectional observational data; no causal inference  
- Limited documentation on original data collection  
- Outliers identified but retained due to uncertainty about removal criteria  
- Predictor set narrower than ideal for full cardiometabolic modeling

---

## **Future Directions**  
- Incorporate composite measures (e.g., Mean Arterial Pressure)  
- Expand predictor set and include longitudinal data  
- Improve outlier diagnostics and removal criteria  
- Validate findings across multiple populations

