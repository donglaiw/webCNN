Crawl urls
==
Pipeline:
1. website list
    - initial top20k website (web_20k.csv)
    - remove adult website (web_20k_g1.csv) 
        = keyword-based
    ```cat urls_20k.csv |grep -v sex|grep -v porn| grep -v adult| grep -v xxx|grep -v gay|grep -v xvideo > urls_20k_g1.csv ``` 
        = manual removal

2. url list: get one url per month per website (query with `wget` Internet
   Archive)
    - start date for each website: query/ [tid=0.1;T_data_url]
    - generate all possible url: 
    - check existence of url: 
    - output url list: 
