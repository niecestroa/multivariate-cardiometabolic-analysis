/* Importing the dataset */

FILENAME REFFILE '/home/u58997590/PH1821_Project/Diabetes_Final_Data_V2.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.Diabetes_unclean;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.Diabetes_unclean; 
RUN;

/* View the first few rows */
PROC PRINT DATA=WORK.Diabetes_unclean (OBS=10);
RUN;

/* Creating cleaned dataset with derived variables */
DATA WORK.Diabetes_clean;
    SET WORK.Diabetes_unclean;

    /* Filtering based on numeric thresholds */
    IF age >= 18 AND
       bmi >= 15 AND bmi <= 55 AND
       pulse_rate >= 40 AND
       systolic_bp <= 210 AND
       glucose >= 4.0 AND glucose <= 13.3;

    /* Creating BMI category */
    LENGTH bmi_cat $12;
    IF bmi < 18.5 THEN bmi_cat = "Underweight";
    ELSE IF bmi < 25 THEN bmi_cat = "Healthy";
    ELSE IF bmi < 30 THEN bmi_cat = "Overweight";
    ELSE bmi_cat = "Obese";

    /* Convert categorical variables to formats */
    gender = PUT(gender, 1.);
    bmi_cat = bmi_cat;

    /* Keep only necessary variables */
    KEEP pulse_rate systolic_bp diastolic_bp glucose age gender hypertensive bmi_cat;
RUN;

/* Summary statistics for the cleaned data */
PROC MEANS DATA=WORK.Diabetes_clean N MEAN STD MIN MAX;
    VAR pulse_rate systolic_bp diastolic_bp glucose age;
RUN;

PROC FREQ DATA=WORK.Diabetes_clean;
    TABLES gender hypertensive bmi_cat / MISSING;
RUN;

/* This step creates a new dataset with only transformed response variables and categorical predictors */

DATA WORK.Diabetes_transformed;
    SET WORK.Diabetes_clean;

    /* Example transformations – replace with actual transformation logic if not already done */
    pulse_rate_t    = LOG(pulse_rate);       /* or your preferred transformation */
    systolic_bp_t   = LOG(systolic_bp);
    diastolic_bp_t  = LOG(diastolic_bp);
    glucose_t       = LOG(glucose);

    /* Keep only transformed responses and categorical variables */
    KEEP pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t age gender hypertensive bmi_cat;
RUN;

/* View the first few rows */
PROC PRINT DATA=WORK.Diabetes_transformed (OBS=10);
RUN;

/* Summary statistics */
PROC MEANS DATA=WORK.Diabetes_transformed N MEAN STD MIN MAX;
    VAR pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t;
RUN;

PROC FREQ DATA=WORK.Diabetes_transformed;
    TABLES gender hypertensive bmi_cat / MISSING;
RUN;

/*-------------------------------------------------------------*/
/*        ONE-WAY MANOVA and POST-HOC TESTS in SAS             */
/*-------------------------------------------------------------*/

/* Perform MANOVA: Response vs BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat;
    MANOVA H=bmi_cat / PRINTE PRINTH;
RUN;
QUIT;

/* Box's M Test for Equality of Covariance Matrices (via POOL=TEST) */
PROC DISCRIM DATA=WORK.Diabetes_transformed POOL=TEST;
    CLASS bmi_cat;
    VAR pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t;
RUN;

/* MANOVA: Response vs Gender */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS gender;
    MODEL pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender;
    MANOVA H=gender / PRINTE PRINTH;
RUN;
QUIT;

/* MANOVA: Response vs Hypertensive */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS hypertensive;
    MODEL pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive;
    MANOVA H=hypertensive / PRINTE PRINTH;
RUN;
QUIT;

/*-------------------------------------------------------------*/
/*           UNIVARIATE POST-HOC TESTS (Bonferroni)            */
/*-------------------------------------------------------------*/

/* Pulse Rate Post-Hoc by BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL pulse_rate_t = bmi_cat;
    MEANS bmi_cat / BON;
RUN;

/* Systolic BP Post-Hoc by BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL systolic_bp_t = bmi_cat;
    MEANS bmi_cat / BON;
RUN;

/* Diastolic BP Post-Hoc by BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL diastolic_bp_t = bmi_cat;
    MEANS bmi_cat / BON;
RUN;

/* Glucose Post-Hoc by BMI Category */
PROC GLM DATA=WORK.Diabetes_transformed;
    CLASS bmi_cat;
    MODEL glucose_t = bmi_cat;
    MEANS bmi_cat / BON;
RUN;

/* Ensure categorical variables */
data Diabetes_transformed;
    set Diabetes_transformed;
    gender = put(gender, $8.);
    bmi_cat = put(bmi_cat, $8.);
    hypertensive = put(hypertensive, $8.);
run;

/* Check sample size and factor levels */
proc freq data=Diabetes_transformed;
    tables gender*bmi_cat hypertensive / missing;
run;

/* MANOVA: gender + bmi_cat (no interaction) */
proc glm data=Diabetes_transformed;
    class gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender bmi_cat;
    manova h=gender bmi_cat / printe printh;
run;

/* MANOVA: gender + bmi_cat (no interaction) */
proc glm data=Diabetes_transformed;
    class gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender bmi_cat;
    /* Bonferroni-adjusted CIs for group means */
    lsmeans gender / cl adjust=bon;
    lsmeans bmi_cat / cl adjust=bon;
run;

/* MANOVA: gender + hypertensive (no interaction) */
proc glm data=Diabetes_transformed;
    class gender hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender hypertensive;
    manova h=gender hypertensive / printe printh;
run;

/* MANOVA: gender + hypertensive (no interaction) */
proc glm data=Diabetes_transformed;
    class gender hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender hypertensive;
    /* Bonferroni-adjusted CIs for group means */
    lsmeans gender / cl adjust=bon;
    lsmeans hypertensive / cl adjust=bon;
run;

/* MANOVA: bmi_cat + hypertensive (no interaction) */
proc glm data=Diabetes_transformed;
    class bmi_cat hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat hypertensive;
    manova h=bmi_cat hypertensive / printe printh;
run;

/* MANOVA: bmi_cat + hypertensive (no interaction) */
proc glm data=Diabetes_transformed;
    class bmi_cat hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat hypertensive;
    /* Bonferroni-adjusted CIs for group means */
    lsmeans hypertensive / cl adjust=bon;
    lsmeans bmi_cat / cl adjust=bon;
run;

/* MANOVA: gender * bmi_cat (with interaction) */
proc glm data=Diabetes_transformed;
    class gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender|bmi_cat;
    manova h=gender bmi_cat gender*bmi_cat / printe printh;
run;

/* Bonferroni-adjusted simultaneous confidence intervals */
/* Estimate group means and perform multiple comparisons */
proc glm data=Diabetes_transformed;
    class gender bmi_cat hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender bmi_cat hypertensive;
    lsmeans gender / adjust=bon alpha=0.05 pdiff cl;
    lsmeans bmi_cat / adjust=bon alpha=0.05 pdiff cl;
    lsmeans hypertensive / adjust=bon alpha=0.05 pdiff cl;
run;

/* Bonferroni CIs for interaction (if needed) */
proc glm data=Diabetes_transformed;
    class gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender|bmi_cat;
    lsmeans gender*bmi_cat / adjust=bon alpha=0.05 pdiff cl;
run;

/* Make sure your categorical variables are formatted as CLASS variables */
data Diabetes_transformed;
    set Diabetes_transformed;
    gender = put(gender, $8.);
    bmi_cat = put(bmi_cat, $8.);
    hypertensive = put(hypertensive, $8.);
run;

/* MANCOVA: Testing BMI categories + age */
proc glm data=Diabetes_transformed;
    class bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat age;
    manova h=bmi_cat age / printe printh;
    lsmeans bmi_cat / cl adjust=bon;
run;

/* MANCOVA: Testing BMI categories + age */
proc glm data=Diabetes_transformed;
    class bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = bmi_cat age;
    lsmeans bmi_cat / cl adjust=bon;
run;

/* MANCOVA: Testing gender categories + age */
proc glm data=Diabetes_transformed;
    class gender;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = gender age;
    manova h=gender age / printe printh;
    lsmeans gender / cl adjust=bon;
run;

/* MANCOVA: Testing hypertensive categories + age */
proc glm data=Diabetes_transformed;
    class hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive age;
    manova h=hypertensive age / printe printh;
run;

/* MANCOVA: Testing hypertensive categories + age */
proc glm data=Diabetes_transformed;
    class hypertensive;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive age;
    lsmeans hypertensive / cl adjust=bon;
run;

/* MANCOVA: Testing hypertensive categories + gender categories */
proc glm data=Diabetes_transformed;
    class hypertensive gender;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive gender;
    manova h=hypertensive gender / printe printh;
run;

/* MANCOVA: Testing hypertensive categories + bmi categories */
proc glm data=Diabetes_transformed;
    class hypertensive bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive bmi_cat;
    manova h=hypertensive bmi_cat / printe printh;
run;

/* MANCOVA: Testing all categories (hypertensive + gender + bmi_cat) */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive gender bmi_cat;
    manova h=hypertensive gender bmi_cat / printe printh;
run;

/* MANCOVA: Testing all predictors (hypertensive + gender + bmi_cat + age) */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive gender bmi_cat age;
    manova h=hypertensive gender bmi_cat age / printe printh;
run;

/* MANCOVA: Testing interaction hypertensive*age + gender + bmi_cat + age */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive|age gender bmi_cat age;
    manova h=hypertensive age hypertensive*age gender bmi_cat / printe printh;
run;

/* MANCOVA: Testing interaction gender*age */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive bmi_cat age gender|age;
    manova h=hypertensive bmi_cat age gender gender*age / printe printh;
run;

/* MANCOVA: Testing interaction bmi_cat*age */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = hypertensive gender bmi_cat|age age;
    manova h=hypertensive gender bmi_cat age bmi_cat*age / printe printh;
run;

/* Model Comparison - Using Full and Reduced Models */
/* Example: Full model with interaction gender*bmi_cat */
proc glm data=Diabetes_transformed outstat=full_stats;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender gender*bmi_cat;
    manova h=gender*bmi_cat / printe printh;
run;

proc glm data=Diabetes_transformed outstat=reduced_stats;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender;
run;

/* You can use a likelihood ratio approach, but manual for MANOVA model comparison in SAS. */

/* Alternative: Fit interaction models one by one */
/* Interaction gender*hypertensive */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender gender*hypertensive;
    manova h=gender*hypertensive / printe printh;
run;

/* Interaction age*hypertensive */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender age*hypertensive;
    manova h=age*hypertensive / printe printh;
run;

/* Interaction age*gender */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender age*gender;
    manova h=age*gender / printe printh;
run;

/* Interaction age*bmi_cat */
proc glm data=Diabetes_transformed;
    class hypertensive gender bmi_cat;
    model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = age hypertensive bmi_cat gender age*bmi_cat;
    manova h=age*bmi_cat / printe printh;
run;

/* Model selection based on AIC manually */
/* Estimate AIC for different models */
proc iml;
   use Diabetes_transformed;
   read all var {pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t age gender hypertensive bmi_cat} into X[c=varNames];
   
   /* Helper function */
   start ComputeAIC(Y, Z);
      n = nrow(Y);
      m = ncol(Y);
      d = ncol(Z);
      b = ginv(Z`*Z) * Z`*Y;
      E = (Y - Z*b)` * (Y - Z*b);
      Sigma = E / (n - d);
      AIC = n*log(det(Sigma)) + 2*m*d;
      return (AIC);
   finish;

   /* Create model matrices */
   Y = X[,1:4];
   intercept = j(nrow(X), 1, 1);

   /* Model 1: age + gender + bmi_cat */
   Z1 = intercept || X[,5] || design(X[,6]) || design(X[,8]);
   aic1 = ComputeAIC(Y, Z1);

   /* Model 2: age + hypertensive + bmi_cat */
   Z2 = intercept || X[,5] || design(X[,7]) || design(X[,8]);
   aic2 = ComputeAIC(Y, Z2);

   /* Model 3: age + gender + hypertensive + bmi_cat */
   Z3 = intercept || X[,5] || design(X[,6]) || design(X[,7]) || design(X[,8]);
   aic3 = ComputeAIC(Y, Z3);

   /* Model 4: age + gender + hypertensive + bmi_cat + interactions */
   Z4 = intercept || X[,5] || design(X[,6]) || design(X[,7]) || design(X[,8])
        || (X[,5]#design(X[,7])) || (X[,5]#design(X[,8])) || (X[,5]#design(X[,6]));
   aic4 = ComputeAIC(Y, Z4);

   print aic1 aic2 aic3 aic4;
quit;

/* Prepare the data: Diabetes_transformed should already exist */

/* Final Multivariate Regression Model without Interaction */
proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = 
         age hypertensive bmi_cat gender / nouni;
   manova h=_all_ / printe printh;
run;

/* Individual Regression Models (Univariate) */
proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model pulse_rate_t = age hypertensive bmi_cat gender;
run;

proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model systolic_bp_t = age hypertensive bmi_cat gender;
run;

proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model diastolic_bp_t = age hypertensive bmi_cat gender;
run;

proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model glucose_t = age hypertensive bmi_cat gender;
run;

/* Final Multivariate Regression Model without Interaction Terms */
proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = 
         age hypertensive bmi_cat gender / nouni;
   manova h=_all_ / printe printh;
run;

/* Final Multivariate Regression Model with Interaction Terms */
proc glm data=Diabetes_transformed;
   class hypertensive bmi_cat gender;
   model pulse_rate_t systolic_bp_t diastolic_bp_t glucose_t = 
         age hypertensive bmi_cat gender 
         age|hypertensive age|bmi_cat age|gender/ nouni;
   manova h=_all_ / printe printh;
run;

