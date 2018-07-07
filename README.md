# SOCR: Electronic Medical Record DataSifter

Simeone Marino, Nina Zhou, and Ivo D. Dinov

Currently, there are no practical, scientifically reliable, and effective mechanisms to share real clinical data containing no clearly identifiable personal health information (PHI) without compromising either the value of the data (by excessively scrambling/encoding the information) or by introducing a substantial risk for re-identification of individuals by various stratification techniques.

## Background

We developed a novel method and a protocol for on-the-fly de-identification of structured Clinical/Epic/PHI data. This approach provides a complete administrative control over the risk for data identification when sharing large clinical cohort-based medical data. At the extremes, the data-governor may specify that either null data or completely identifiable data is generated and shared with the data-requester. This decision may be based on data-governor determined criteria abut access level, research needs, etc. For instance, to stimulate innovative pilot studies, the data office may dial up the level of protection (which may naturally devalue the information content in the data), whereas for more established and trusted investigators, the data governors may provide a more egalitarian dataset that balances preservation of information content and sensitive-information protection.

In a nutshell, responding to requests by researchers interested in examining specific healthcare, biomedical, or translational characteristics of multivariate clinical data, the DataSifter allows data governors, like Healthcare Systems, to filler, export, package and share sensitive clinical and medical data for large population cohorts.

## Technology

The DataSifter protocol is based on an algorithm that involves (data-governor controlled) iterative data manipulation that stochastically identifies candidate entries from the cases (e.g., subjects, participants, units) and features (e.g., variables or data elements) and subsequently selects, nullifies, and imputes the information. This process heavily relies on statistical multivariate imputation to preserve the joint distributions of the complex structured data archive. At each step, the algorithm generates a complete dataset that in aggregate closely resembles the intrinsic characteristics of the original cohort, however, on the individual level (e.g., rows), the data are substantially obfuscated. This procedure drastically reduces the risks for subject re-identification by stratification, as meta-data for all subjects is repeatedly and lossily encoded. A number of techniques including mathematical modeling, statistical inference, probabilistic (re)sampling, and imputation methods are embedded in the DataSifter information obfuscation protocol.

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

This step can calculate a variety of dissimilarity or distance metrics between cases/subjects. The function `ecodist::distance()` is written for extensibility and understandability, and it may not be efficient for use with large matrices. Initially, we only select numeric features. Later we may need to expand this to select factors/categorical features and strings/unstructured features. The default distance is the Bray-Curtis distance (more stable/fewer singularities). The results of `distance()` is a lower-triangular distance matrix as an object of class “dist”. With N representing the total number of cases, then the size of the distance vector is N(N−1)/2.

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

An example of the selection of the values for k0-k4 is shown below.
More information on DataSifter implementation and Validation is provided at www.DataSifter.org.
```
{r, Selection of k0-k4, eval=FALSE}
## Pick a value from each of the k_options below and type it into the k_raw
k0_options <- c(0,1)
k1_options <- c(0,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40)
k2_options <- c(0,1,2,3,4)
k3_options <- c(0,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1)
k4_options <- seq(0.01,1,0.01)

# These are the values selected for this example
k0 <- 0 # swapping of unstructured data features
k1 <- 0.5 # % of data removal from the entire dataset (except unstructured features) 
k2 <- 2   # how many times to perform imputation on the "disrupted" dataset after k1
k3 <- 1 # swapping of structured features (right now done on ALL features except the unstructured ones)
k4 <- .5 # % of closest neighbors to choose from
```

## `DataSifter` Installation

To install `DataSifter` lite, run the following two commands in your R/RStudio shell:
```
# install.packages("devtools")  # just in case you don't already have the R devtools package installed.
library(devtools)
install_github("SOCR/DataSifter")
```


