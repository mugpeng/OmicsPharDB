# OmicsPharDB
A database that includes the largest published studies investigating the cancer cell lines to chemical compound treatment, and the association between drug sensitivity and multi-omics.

# Contact with me

Feel free to talk with me if you find any bugs or have any suggestions. :)

Email: mugpeng@foxmail.com, mugpeng@outlook.com



# TODO

long time goal:

- drug combination
- more data
  - database
  - in vivo
- make useful function into R package for coding users
- features combination



important:

- specific type
  - compare after group, subtype compare (add into omic-drug pair)
- make function into package for data scientist 
- interrupt opt without redundant calculation
- multithread or others to accelerate 
- too much obj names (replicate obj names) 
- Check and comment backend code
  - Recheck the drug, omics data, if error or omit
  - cell and drug filter, tsne plot, impute
- ~~Upload consensus processed data~~
- ~~download button~~
- ~~manual book~~
- ~~significant pairs~~
  - multicores?
- ~~deploy to github~~



others:

- change name ccle_exp into ccle_mRNA
- rewrite DrugOmicPair part
- ~~Specific test page(per function per test)~~
- check discreate data(cells without omics info in sensitivity comparison)
- check drug anno files, cell anno files
- ~~drug similarity~~
- ~~sensitivity and omics from different projects~~



# Update

## 01/22/24

Upload data to zenodo: https://zenodo.org/records/10553615



Btw, aliyunpan is really hard to use:

![](http://cos01.mugpeng.top/img/b637d263b74782649ceb0aa4c2c765d.png)



Fix the bugs:

![](http://cos01.mugpeng.top/img/20240122154828.png)



## 01/19/24

Deploy the project mini version on shiny, github, private website.



## 01/17/24

Version 1.0 has been released, containing data from six projects: CTRP1, CTRP2, PRISM, GDSC1, GDSC2, and gCSI. It also includes three analysis modules offering four functions for further processing and exploration of the data.

![image-20240116134858293](http://cos01.mugpeng.top/img/image-20240116134858293.png)

For more details, please check the `Others\DataInfo\Table1.docx` in backend directory:

![](http://cos01.mugpeng.top/img/20240118094033.png)

You can scroll down this readme, and download the raw data, scripts and others at *For developer* part.



# How to run

## Full version

Fork the repository locally, open Rproj, just run `App.R`.

![image-20240117162353939](http://cos01.mugpeng.top/img/image-20240117162353939.png)



Input data is very large, you can download throuth:

OmicsPhar_Front_Input_0122: https://zenodo.org/records/10553615

Then put the input file in the work dir.



## Test version(maybe outmoded)

Alternatively, you can use this code to automatically download and execute the packaged shiny project. However, please note that the test project utilizes sampled features (only 100):

```
runGitHub("OmicsPharDB_github_testRun", "mugpeng")
```

![](http://cos01.mugpeng.top/img/20240119155745.png)



Or visit the website deployed at shiny:

[OmicsPharDB (mugpeng@foxmail.com)](https://mugpeng.shinyapps.io/OmicsPharDB_v1/)



# Tutorial

![image-20240116134743363](http://cos01.mugpeng.top/img/image-20240116134743363.png)

The website consisted of four main sections (pages): 1) Drug-omics pairs analysis; 2) Profile Display; 3) Significant analysis of features database; and 4) Statistics Information, which is the final page. The tour will start from this last page.



Following the principle of least change, AAC values from gCSI are rescaled such that a lower metric indicates higher sensitivity across all datasets. (AAC2 = max(AAC) - AAC)

![image-20240116150920858](http://cos01.mugpeng.top/img/image-20240116150920858.png)

Lower scores on metric scales mean stronger drug sensitivity.



## Statistics Information

The omics data we collected including mRNA expression, protein data, copy number variant(CNV), gene fusion, methylation, mutation(gene mutation, and a specific amino acid change).



In vitro cell line pharmacogenetics studies can be categorized into CCLE, GDSC, and other projects (produced by different insititutions). CCLE, GDSC projects produce the genomics data, then other experiments are conducted to generate drug data used the same cell lines one of the projects.

The cell lines from the Cancer Cell Line Encyclopedia (CCLE) were used to generate several drug sensitivity projects, including CTRP1, CTRP2, and PRISM. Meanwhile, the Genomics of Drug Sensitivity in Cancer (GDSC) project generated GDSC1 and GDSC2. And Genentech Cell Screening Initiative (gCSI) project has its own omics and drug response data.



The PRISM project tests the highest number of drugs, while GDSC1 focuses on testing the largest number of cells.

![image-20240116134858293](http://cos01.mugpeng.top/img/image-20240116134858293.png)

Projects have tested same drugs and same cells. When multiple projects test the same drugs and cells, there is typically a higher degree of overlap between projects that use the same cell lines.

![image-20240116140858989](http://cos01.mugpeng.top/img/image-20240116140858989.png)

![image-20240116140840856](http://cos01.mugpeng.top/img/image-20240116140840856.png)

The cell lines are mainly from lung cancer, colorectal cancer, and ovarian cancer:

![image-20240116141100546](http://cos01.mugpeng.top/img/image-20240116141100546.png)

Also there is annotation for cell and drug:

![image-20240116143433413](http://cos01.mugpeng.top/img/image-20240116143433413.png)

![image-20240116143440528](http://cos01.mugpeng.top/img/image-20240116143440528.png)



You can search drugs of interests.

![image-20240116143707243](http://cos01.mugpeng.top/img/image-20240116143707243.png)



## Main Function

### 1) Drugs-omics pairs analysis

This feature allowed user to explore the association between a selected drug resistance event and a certain omic. For continuous omics data like mRNA, methylation, copy number variant, protein, spearman correlation was calculated. While for discrete omics data such as mutation genes, mutation gene points or gene fusions, wilcoxon test is chosen for testing Signification.

![image-20240116170237024](http://cos01.mugpeng.top/img/image-20240116170237024.png)

The title of each plot indicates the source of the omics and drug response data. For example, a plot titled `gdsc_ctrp1` would mean the omics data is from the GDSC project, while the drug sensitivity data is from the CTRP1 project, as mentioned in the initial *Statistics Information* section. Personally, I think comparing cells data from different organizations (e.g. GDSC vs CCLE) is reasonable for analyzing correlations, as we are primarily interested in examining the relationship between omic features and drug responses, regardless of the original data source. Combining data from multiple sources can provide a more comprehensive view of these relationships.

The upper figure shows that the gene expression of ABCC3 is significantly positively correlated with sensitivity to the drug YM-155 across all ten dataset combinations. This correlation could potentially be explained by the known function of the ABCC3 gene. Specifically, ABCC3 encodes an ATP-binding cassette transporter protein that is involved in exporting various molecules, including drugs, out of cells via active transport across cell membranes. Given its role in drug efflux, higher ABCC3 expression may correlate with increased efflux and reduced intracellular concentration of YM-155, resulting in greater resistance to the drug's effects. This might explain the observed positive correlation between ABCC3 expression levels and higher values for YM-155.



Another example is gene mutation of TP53 and drug AMG-232, it is obvious that the wild type TP53 has significant higher sensitivity:

![image-20240116150340720](http://cos01.mugpeng.top/img/image-20240116150340720.png)

AMG-232 is an inhibitor of the p53-MDM2 interaction. Mutated tp53 may deactivate the suppressor program induced by AMG-232 through disruption of this interaction: [p53-family proteins and their regulators: hubs and spokes in tumor suppression | Cell Death & Differentiation (nature.com)](https://www.nature.com/articles/cdd201035)



### 2) Profile Display

This page consists of two parts.

![image-20240116152423915](http://cos01.mugpeng.top/img/image-20240116152423915.png)

#### features across different types

The first one is *features across different types*. 

![image-20240116153514112](http://cos01.mugpeng.top/img/image-20240116153514112.png)

This page is designed to detect covariates like cell source types, age, and gender. Currently, only cell source type detection is available. The user chooses a certain drug, and it will return all datasets including this drug visualized as a boxplot with the significant test to check if there is an association between subtypes and a certain drug sensitivity metric.



It is clearly that SNX-2112, a selective Hsp90 inhibitor, potently inhibits tumor in multiple myeloma and other hematologic tumors, has higher sensitivity in leukemia and lymphcma.



For discrete feature types such as gene fusion, mutation(gene mutation, and a specific amino acid change), Chi-squared test is utilized:

![image-20240116155707258](http://cos01.mugpeng.top/img/image-20240116155707258.png)



#### Profile of drug sensitivity

The second part was the profile of drug sensitivity. The T-SNE dimensionality reduction plots were generated for comparing each drug for inspecting 1) if two drugs with similar drug targets but showing different drug sensitivity or 2) if two drugs with different drug targets but having close drug sensitivity. Besides, the median versus variance scatter would tell if a drug had a wide range sensitivity in different cell lines and its sensitivity rank in the database.

For example, MAD&MEDIAN plot indicated that VINCRISTINE was an effective drug both in CTRP2, GDSC2, PRISM, And provenly, it was a FDA-approved clinical drug for many types of tumors.

![image-20240116154452726](http://cos01.mugpeng.top/img/image-20240116154452726.png)

![image-20240116154538439](http://cos01.mugpeng.top/img/image-20240116154538439.png)

![image-20240116154601931](http://cos01.mugpeng.top/img/image-20240116154601931.png)

But not on the top in gCSI: 

![image-20240116154828783](http://cos01.mugpeng.top/img/image-20240116154828783.png)

### 3) Features database significant analysis

This analysis module helped people to conduct a significant test between a targeted feature(a drug or an omic) and all the features in a particular feature dataset grouped by their collected databases in a large scale.

The effect and p-value is calculated depend on the data types:

- For continuous features compared to continuous datasets (e.g. drug A levels versus all CNV features), the Pearson correlation coefficient R is used, ranging from 0-1. 
- For discrete features compared to discrete databases (e.g. TP53 mutation events versus all collected gene fusions), the odds ratio is used. An odds ratio >1 indicates the selected feature has a higher probability of the observed association/events in the database. P-value is calculated using the Wilcoxon test.
- For discrete features compared to discrete databases, the log2 fold change (events/wildtype) is also used as the effect measure. P-value is generated from a Chi-squared test.

A feature-database pair will be considered statistically significant if both of the following criteria are met:

1. The absolute value of the effect size is greater than 0.2.
2. The p-value is less than 0.05.



We will find the potential related mRNA with Lapatinib as an example:

![image-20240116172531752](http://cos01.mugpeng.top/img/image-20240116172531752.png)



Frequency table has two columns, frequency col counts the number of pairs labeled as significant in all databases containing this pair. Proportion col is the fraction of significant pair in all pairs. You can choose the topmost to further examination with result table.

![image-20240117161051412](http://cos01.mugpeng.top/img/image-20240117161051412.png)

For example, we are interested about CDH1 gene, which is a classical cadherin of the cadherin superfamily, Mutations in this gene are correlated with gastric, breast, colorectal, thyroid and ovarian cancer. Loss of function of this gene is thought to contribute to cancer progression by increasing proliferation, invasion, and/or metastasis, described from genecode: [CDH1 Gene - GeneCards | CADH1 Protein | CADH1 Antibody](https://www.genecards.org/cgi-bin/carddisp.pl?gene=CDH1&keywords=CDH1)

We can search this gene by the search box at the top right edge. The results indicate that higher expression of CDH1 is correlated with increased sensitivity to LAPATINIB. As drug resistance metrics are negatively correlated with drug sensitivity, a higher CDH1 expression level tends to predict greater LAPATINIB sensitivity.

![image-20240117161119979](http://cos01.mugpeng.top/img/image-20240117161119979.png)

A downloadable button is also provided, allowing users to access a CSV file containing the data. This CSV file can then be used for additional analyses or data processing as needed.

![image-20240117161344003](http://cos01.mugpeng.top/img/image-20240117161344003.png)



A simple online search reveals that CDH1 is related to ERBB2, and ERBB2 is a validated target of LAPATINIB. This suggests that CDH1 expression levels may help determine a tumor's response to LAPATINIB treatment, potentially through its relationship to the drug's primary target, ERBB2. 

![image-20240117160239539](http://cos01.mugpeng.top/img/image-20240117160239539.png)



By the way, we can also double check it through *Drugs-omics pairs analysis* module:

![image-20240117160637855](http://cos01.mugpeng.top/img/image-20240117160637855.png)



# Tips

- Please be patient

The features database significant analysis module may take long time.

![image-20240117152345215](http://cos01.mugpeng.top/img/image-20240117152345215.png)



# For developers

## Raw data and back end

- GDSC

mRNA array expression:

[Home (cancerrxgene.org)](https://www.cancerrxgene.org/gdsc1000/GDSC1000_WebResources/Home.html) : Cell_line_RMA_proc_basalExp.txt

other omics: 

https://orcestra.ca/pset/10.5281/zenodo.7829919

GDSC1,2 drug AUC:

https://depmap.org/portal/download/all/,  select "Sanger GDSC1 and GDSC2" dataset.  



- CCLE

All Omics: 

https://depmap.org/portal/download/all/



CTRP1,2 drug:

https://portals.broadinstitute.org/ctrp.v1/ 

https://portals.broadinstitute.org/ctrp.v2.1/   

[Index of /Public/Broad (nih.gov)](https://ctd2-data.nci.nih.gov/Public/Broad/)

[CTD² Data from The Broad Institute - NCI (cancer.gov)](https://www.cancer.gov/ccg/research/functional-genomics/ctd2/data-portal/broad-institute)



PRISM drug:

  https://depmap.org/portal/download/all/,  select "PRISM Repurposing 19Q4 Primary Files" dataset.  



- gCSI

Both omics and drug data are from Orcestra:

https://orcestra.ca/pset/10.5281/zenodo.4737437  



For more details, please check the `Others\DataInfo\Table1.docx`:

![](http://cos01.mugpeng.top/img/20240118094033.png)

More details on the raw data, scripts, and backend preprocessing can be downloaded:

OmicsPharBackend_240122: [OmicsPhar Extra Data Repository (zenodo.org)](https://zenodo.org/records/10553615)

The methodology and implementation details can be found in the preprint (may now be outdated):

[OmicsPharLeuDB: an integrative database for mining pharmacogenomic data in acute lymphoblastic leukemia | bioRxiv](https://www.biorxiv.org/content/10.1101/2023.09.14.557519v1)



## Code structure

```
├─App.R
├─Input
│  ├─01
│  ├─02
│  ├─03
│  ├─04
│  └─05
├─Log
│  └─图片
├─Modules
├─readme_backup
│  └─图片
├─Script
└─Test
    └─Test_Module
```

![](http://cos01.mugpeng.top/img/20240118103859.png)



I have modularize my shiny project, The UI, server part, module scripts in the Modules files, and panel displayed on the websites are interconnected with each other:

![](http://cos01.mugpeng.top/img/20240118105247.png)

![](http://cos01.mugpeng.top/img/20240118105400.png)

![](http://cos01.mugpeng.top/img/20240118110228.png)

![](http://cos01.mugpeng.top/img/20240118110240.png)

![](http://cos01.mugpeng.top/img/20240118105345.png)



If you would like to fork this project and add new modules. there are several steps in short.

1) Copy the existed module scripts.
2) Change the UI and server for your own needs.
3) Create a new `TabPanel` and use `callModule` function to call the corresponded server function.
4) Test them until all bugs are eradicated.
5) Share you coool new function with you friends, and I encourage you to pull requests to me! 
6) Celebrate~



You can also use the `Test` directory to test both new function and new modules:

![](http://cos01.mugpeng.top/img/20240118110812.png)





## Ways to learn shiny

[Shiny - Welcome to Shiny](https://shiny.posit.co/r/getstarted/shiny-basics/lesson1/index.html)

[Welcome | Mastering Shiny](https://mastering-shiny.org/)

Chinese: [#shiny](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU5ODc3OTA0NQ==&action=getalbum&album_id=2812488349889626113&scene=173&subscene=7&sessionid=undefined&enterid=0&from_msgid=2247492282&from_itemidx=1&count=3&nolastread=1#wechat_redirect)



## Walk with me

If you have an interest in shiny, pharmacogenomics, or bioinformatics, and if you're enthusiastic about contributing to the open-source community, feel free to join me.

ps: I'm also open to supporting you in your endeavors, carry me (抱紧你的大腿).

I can also offer guidance and provide you with the opportunity to co-author a paper based on your contributions.



Currently, there are several difficulties:

- multithread or others to accelerate 

The *Features database significant analysis* module is quite time-consuming.

The selected feature needs to perform statistical calculations using all the feature data in the intersected database. Initially, I utilized Snowfall for parallel computing, but I abandoned it due to low efficiency during the launch stage(need to initiate every time). 

Besides, snowfall could have potential risks that may induce error by garbage collection when interrupt it.

similar question: [r - Snowfall sfApply() is slower than apply() - Stack Overflow](https://stackoverflow.com/questions/13209668/snowfall-sfapply-is-slower-than-apply)

Are there any alternative methods to enhance the calculation speed?



- interrupt opt without redundant calculation

https://stackoverflow.com/questions/30587883/is-it-possible-to-stop-executing-of-r-code-inside-shiny-without-stopping-the-sh

https://stackoverflow.com/questions/34226789/getting-shiny-to-update-the-ui-and-and-run-long-calculation-afterwards

shiny stop calculation when change other operation

For example, the user select an unwanted pairs, how to interrupt it instead of unnecessary waiting or reopen the project?  

![](http://cos01.mugpeng.top/img/20240118134823.png)



- Out of memory

I have decided to upload the project to my own server with 2 cores and 2GB of memory, as well as the shinyapp. However, both of them encountered a similar error while loading the packages:

![](http://cos01.mugpeng.top/img/20240119160154.png)

Interestingly, I have successfully deployed a similar project on ShinyApp without encountering this error: [Leukemia Multi-Omics_Drugs Sensitivity Database (mugpeng@foxmail.com)](https://mugpeng.shinyapps.io/leu_web_english_peng_v2/), even though it also required loading the `plotly` package.

 

After several attempts, it has become clear that the reason for the error is the large size of the full dataset, which exceeds the capacity of my small memory server. This conclusion is drawn from the fact that the project runs successfully with the test data. However, a new problem arises: if I still wish to run the project on my limited server, are there any alternative solutions? For instance, could utilizing RMySQL be a viable tactic?

![](http://cos01.mugpeng.top/img/20240119162242.png)



- Cannot find the object

![](http://cos01.mugpeng.top/img/20240122154828.png)

I found some objects created at the main App.R script cannot be accessed through the module scripts.

For example, I create global env:

![](http://cos01.mugpeng.top/img/20240122154943.png)

And used in the module:

![](http://cos01.mugpeng.top/img/20240122155005.png)

But the beforementioned error appears.

# .
