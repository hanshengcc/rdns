# https://le6-1-103at400.pulsedmedia.com/public-indexx/dns_data/

#安装aria2c
sudo snap install aria2c

#下载最新的RDNS数据库
aria2c -s 16 -x 16 -k 1M -c --summary-interval=0 " https://le6-1-103at400.pulsedmedia.com/public-indexx/latest_rdns.json.gz"


#需要安装python3
sudo snap install duckdb


# 这会创建一个名为 dns_warehouse.db 的数据库文件
duckdb dns_warehouse.db "CREATE TABLE rdns AS SELECT ip, ptr[1] AS domain FROM read_json_auto('2026-01_rdns_ipv4.json.gz')"

# 导出全部蜘蛛到csv
duckdb dns_warehouse.db -csv -c "
SELECT 

    CASE 
        WHEN domain LIKE '%googlebot%' THEN '谷歌蜘蛛'
        WHEN domain LIKE 'baiduspider%' THEN '百度蜘蛛'
        WHEN domain LIKE 'msnbot%' OR domain LIKE '%msnbot%' THEN '必应蜘蛛'
        WHEN domain LIKE 'sogouspider%' THEN '搜狗蜘蛛'
        WHEN domain LIKE 'bytespider%' THEN '字节蜘蛛'
        WHEN domain LIKE 'shenmaspider%' THEN '神马蜘蛛'
        ELSE 'Other'
    END AS spider_type
    ip, 
    domain,
FROM rdns
WHERE 
    domain LIKE '%googlebot%' OR 
    domain LIKE 'baiduspider%' OR 
    domain LIKE 'msnbot%'OR
    domain LIKE 'sogouspider%' OR 
    domain LIKE 'bytespider%' OR
    domain LIKE 'shenmaspider%'
" > all_search_engines.csv

# 查询全部蜘蛛的数量
duckdb dns_warehouse.db "
SELECT 
    CASE 
                WHEN domain LIKE '%googlebot%' THEN '谷歌蜘蛛'
        WHEN domain LIKE 'baiduspider%' THEN '百度蜘蛛'
        WHEN domain LIKE 'msnbot%' OR domain LIKE '%msnbot%' THEN '必应蜘蛛'
        WHEN domain LIKE 'sogouspider%' THEN '搜狗蜘蛛'
        WHEN domain LIKE 'bytespider%' THEN '字节蜘蛛'
        WHEN domain LIKE 'shenmaspider%' THEN '神马蜘蛛'
        ELSE 'Other_Spider'
    END AS spider_name,
    count(*) AS total_count
FROM rdns
WHERE 
    domain LIKE '%googlebot%' OR 
    domain LIKE 'baiduspider%' OR 
    domain LIKE 'msnbot%'OR
    domain LIKE 'sogouspider%' OR 
    domain LIKE 'bytespider%' OR
    domain LIKE 'shenmaspider%'
GROUP BY spider_name
ORDER BY total_count DESC;
"