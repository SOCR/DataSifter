# SOCR: Electronic Medical Record DataSifter

Simeone Marino, Nina Zhou, and Ivo D. Dinov

Currently, there are no practical, scientifically reliable, and effective mechanisms to share real clinical data containing no clearly identifiable personal health information (PHI) without compromising either the value of the data (by excessively scrambling/encoding the information) or by introducing a substantial risk for re-identification of individuals by various stratification techniques.

## Background

We developed a novel method and a protocol for on-the-fly de-identification of structured Clinical/Epic/PHI data. This approach provides a complete administrative control over the risk for data identification when sharing large clinical cohort-based medical data. At the extremes, the data-governor may specify that either null data or completely identifiable data is generated and shared with the data-requester. This decision may be based on data-governor determined criteria abut access level, research needs, etc. For instance, to stimulate innovative pilot studies, the data office may dial up the level of protection (which may naturally devalue the information content in the data), whereas for more established and trusted investigators, the data governors may provide a more egalitarian dataset that balances preservation of information content and sensitive-information protection.

In a nutshell, responding to requests by researchers interested in examining specific healthcare, biomedical, or translational characteristics of multivariate clinical data, the DataSifter allows data governors, like Healthcare Systems, to filler, export, package and share sensitive clinical and medical data for large population cohorts.

## Technology

The DataSifter protocol is based on an algorithm that involves (data-governor controlled) iterative data manipulation that stochastically identifies candidate entries from the cases (e.g., subjects, participants, units) and features (e.g., variables or data elements) and subsequently selects, nullifies, and imputes the information. This process heavily relies on statistical multivariate imputation to preserve the joint distributions of the complex structured data archive. At each step, the algorithm generates a complete dataset that in aggregate closely resembles the intrinsic characteristics of the original cohort, however, on an the individual level (e.g., rows), the data are substantially obfuscated. This procedure drastically reduces the risks for subject re-identification by stratification, as meta-data for all subjects is repeatedly and lossily encoded. A number of techniques including mathematical modeling, statistical inference, probabilistic (re)sampling, and imputation methods are embedded in the DataSifter information obfuscation protocol.

## Applications

The main applications of the DataSifter include:

- Sharing electronic medical or health records (EMR/EHR): This allows researchers and non-clinical investigators access to sensitive data and promote scientific modeling, rapid interrogation, exploratory, and confirmatory analytics, as well as discovery of complex biomedical processes, health conditions, and biomedical phenotypes.

- Sharing Biosocial Data: Allowing engineers and data scientists to examine sensitive CMS/Medicare/Census/HRS data without compromising the risk for participant re-identification.

- Other government data (e.g., IRS) may similarly be shared as DataSifter outputs without privacy concerns.

## Advantages

The new method has some advantages:

1. This algorithm permits computationally efficient implementations - a feature that is attractive for data governors that deal with large amounts of data, receive many data requests, and need innovative strategies for data interrogation.

2. On the individual level, the DataSifter scrambles sensitive information that can be used for stratification based data re-identification attacks, thus reducing security risks. At the same time, it preserves the joint distribution of the entire cohort-based data, thus, facilitating the urgent need to expedite data interpretation, derive actionable knowledge, and enable rapid decision support).

3. As the data governors can keep their mapping between the native subject identifiers (e.g., EMR, SSN) and the study-specific subject IDs (sequential or random), the size and complexity of the data collection may easily be extended to add additional longitudinal data augmenting previously generated DataSifter output datasets. This allows a mechanism for meaningful aggregation of obfuscated data.

## Software/materials

In the implementation of DataSifter, we used SOCR libraries (http://socr.umich.edu/html/SOCR_CitingLicense.html) and R software (https://www.r-project.org/Licenses/). More information is provided at www.DataSifter.org.

## Notes
In terms of implementation, repeated user requests for the same cohort data (e.g., different η values) should be discouraged and viewed with suspicion. Multiple copies of different iterations of DataSifter-generated data of the same cohort may be cleverly mined and merged in an effort to reconstruct the original (sensitive) data. 

The DataSifter site provides additional information about this new technology. Handling unstructured data, strings or non-ordinal data: By default, the DataSifter randomly swaps such features between cases/participants, subject to determining close pairs of cases using appropriate distance metrics defined on the structured quantitative features in the data. More advanced techniques using NLP and ML methods may be employed to transform unstructured data into structured data elements that can be jointly utilized in the DataSifting process.

## List of features to be handled

Ideally we want to know 5 lists of feature types as an input:

1. LIST1: List of features to remove for privacy or other reasons.

2. LIST2: List of dates.

3. LIST3: List of categorical features (i.e., binomial/multinomial).

4. LIST4: List of unstructured features (e.g., medicine taken with a dose spec and type of release).

5. LIST5: List of features with known dependencies (e.g., bmi = f(weight, height)), or temporal correlation (e.g., weight/height of a kid over time). Right now it is empty

List1 is provided by the data governor. After the features in List1 are removed, constant features are also removed if present in the dataset.

List2 of date features is provided by the data governor. The obfuscation of date features will be done by complying with the time resolution Δt
requested (e.g., years, months, weeks, days, hours, minutes,….). Right now we obfuscate with Δt=year.

List3 of categorical features is automated, enforcing the following criteria for defining a categorical feature x
(here N

represents the total number of cases):

if (unique(x)>[3∗log(N)]), then x

is likely NOT CATEGORICAL.

List4 and List5 are specified by the data governor.

## Similarity/Distance metric between cases

This step can calculate a variety of dissimilarity or distance metrics between cases/subjects. The function ecodist::distance() is written for extensibility and understandability, and it may not be efficient for use with large matrices. Initially, we only select numeric features. Later we may need to expand this to select factors/categorical features and strings/unstructured features. The default distance is the Bray-Curtis distance (more stable/fewer singularities). The results of distance() is a lower-triangular distance matrix as an object of class “dist”. With N representing the total number of cases, then the size of the distance vector is N(N−1)2.

## Five Components of the Data Sifter η

a) First component: k0
The first component of the DataSifter is k0.
k0: binary option [0,1] to swap/obfuscate or not the unstructured feature defined in list4. It is not relevant for computing distance between cases.

b) Second and third component: k1 and k2
The second and third component of the DataSifter are k1 and k2. They are linked since the obfuscation step k1 is repeated as many times as specified in k2.
k1: introduction of % of artificial missing values + imputation. In this example we are using values between 0% up to 40% with increments of 5%.
k2: how many time to repeat k1. In this example we are using 5 options: [0,1,2,3,4].

c) Forth component: k3
The fourth element of the data sifter is k3.
k3: fraction of features (among all the features except the unstructured ones) to swap/obfuscate on ALL the cases. For each case, the case to be swapped is chosen from a certain radius (distance, see the fifth component k4). In this example we are using values between 0% up to 100% with increments of 5%.

d) Fifth component: k4
The fifth element of the data sifter is k4.
k4: the swapping step k3 is performed on each case by sampling among the k4-percentile of its neighbors (fraction of closest neighbors from which to select the case to be swapped). In this example we are using values between 1% up to 100% with increments of 1%. We are not computing the contribution of k4 into the Data Sifter slider η yet.

The selection of the values for k0-k4 is done in Section 1.9 below of this Rmd script.

## Pick a value from each of the K_options below and type it into the k_raw
k0_options <- c(0,1)
k1_options <- c(0,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40)
k2_options <- c(0,1,2,3,4)
k3_options <- c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1)
k4_options <- seq(0.01,1,0.01)

## Select the values for the 5 options k0-k4 of the DataSifter

# These are the values selected for this example
k0 <- 0 # swapping of unstructured data features
k1 <- 0.5 # % of data removal from the entire dataset (except unstructured features) 
k2 <- 2   # how many times to perform imputation on the "disrupted" dataset after k1
k3 <- 1 # swapping of structured features (right now done on ALL features except the unstructured ones)
k4 <- .5 # % of closest neighbors to choose from

## Comparing Raw and Sifted Data records and distributions

We compare below 2 records across 10 features in Figure 1. This step selects only double features for the record and the beanplot comparisons. It samples from the selected features, 10 features that are numeric and generates a table with Raw vs Sifted records, as well as beanplots for comparing the distributions. The goal of the Data Sifter is to obfuscate single records without disrupting the overall distribution of features. The magnitude of obfuscation is set by the five options selected to generate the sifter slider normalized value η

between 0 and 1. Sometimes, since we swap feature values between cases that are within a certain radius (set by k4), there is a possibility to swap back and forth between the same cases. We will eventually place a control on this occurrence, if necessary.


## Validation Results
Protecting sensitive information (e.g., PHI)

The DataSifter privacy protection power relies heavily on user-defined privacy level and data structure. We measure the privacy level for each subject as percent of identical feature values (PIFV) in both sifted and original data. When eta is close to one, PIFVs are close to 0% for numerical features. For categorical features, the algorithm is able to provide PIFVs similar to the lowest PIFV between any pair of different subjects in the original dataset.

Figure 2 illustrates the relationship between median PIFVs for ABIDE dataset and user-defined privacy levels. The clear negative relationship between the two characteristics indicates that the data governor’s specification of η
does provide increasing patient privacy protection levels. When a user requires higher levels of obfuscation, PIFVs are approaching zero percent. In this scenario, patient privacy is highly protected. Data hackers are almost impossible to filter the targeted patients via known feature values. This is because he cannot distinguish between imputed or exchanged values with the real feature values. Moreover, the untouched proportion of data is relatively small. Although the data hacker might request multiple queries, the overlap untouched proportion would be small when η

is high. The small proportion of “true” values protects patient identity and allows the data user to request for a small number of overlapping queries.
Figure 2: Median Percent Feature Match under Different Etas-ABIDE data

Figure 2: Median Percent Feature Match under Different Etas-ABIDE data

Figure 3 shows the PIFV for simulated data. Using 6 variables, the median PIFV has a gradually decreasing pattern as η→1
. Note that since the feature set includes a binary variable, the data simulated from the empirical distribution (η=1) still has a variable y

matching the original dataset for the majority of cases.
Figure 3: Median Percent Feature Match under Different Etas-Simulated data

Figure 3: Median Percent Feature Match under Different Etas-Simulated data
2.2 Maintained utility information of the original dataset.

We used simulated datasets to test the algorithm’s ability to maintain utility information. A binary outcome(y) and five independently and identical distributed covariates (xi,i=1,...,5) are simulated. All covariate distributed uniformly ranging from 0 to 1. The binary outcome is generated by the following formula:

logit[P(y=1|X)]=10+10∗x1+10∗x2−5∗x3−20∗x4+5∗x5.

We added an unstructured variable to the simulated data to meet the required data format. The DataSifter generated outputs for 11 η
values, 0≤η≤1 are reported below. The parameter estimates, prediction accuracy, and AUC (Area Under the ROC) are computed and compared with the model built from original data (prior to obfuscation). Note that for η=0, we have the logistic regression fitted on the original data, whereas η=1 correspond to null synthetic data. Moreover, the prediction accuracy is calculated using the original data as test data. We found that the DataSifter preserved a fair amount of the information energy for moderate η values, whereas for increasing η the algorithm compromises the energy of the data.

The parameter estimates and model prediction accuracy for logistic regressions are listed in Table 1. From small to large η, the parameter estimates gradually diverge from the original data. The prediction accuracy is very high for all models.
Table continues below Parameters 	Original Model 	η = 0.1 	η = 0.2 	η = 0.3 	η = 0.4
(Intercept) 	7.573 	6.221 	7.463 	2.002 	2.992
x_1 	10.09 	6.52 	9.787 	4.537 	9.836
x_2 	9.374 	4.825 	6.835 	2.843 	9.489
x_3 	-3.915 	-2.657 	-4.551 	-0.95 	-1.147
x_4 	-17.9 	-12.57 	-16.42 	-4.442 	-13.66
x_5 	5.965 	4.26 	5.344 	1.271 	4.145

Prediction_accuracy 	0.962 	0.956 	0.955 	0.928 	0.949
AUCs 	0.8673 	0.8593 	0.8913 	0.639 	0.8694
η = 0.5 	η = 0.6 	η = 0.7 	η = 0.8 	η = 0.9 	η = 1
1.307 	6.631 	3.852 	-0.6713 	11.92 	1.56
8.053 	4.254 	2.871 	8.201 	2.387 	0.09066
2.274 	4.446 	1.808 	6.647 	-0.03014 	0.1664
-1.539 	-1.934 	-2.527 	-6.165 	-2.046 	0.05799
-4.768 	-11.43 	-5.482 	-5.888 	-12.95 	0.2207
2.028 	1.722 	2.418 	7.039 	-1.707 	0.5108
0.936 	0.955 	0.941 	0.889 	0.885 	0.904
0.7412 	0.8727 	0.7346 	0.8269 	0.7781 	0.5
Table 1: Model Comparisons.
