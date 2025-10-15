install.packages("redlist")
library(redlist)

bj_reldist <- rl_countries(code = "BJ", page = NA)

ampibian <- rl_phylum(phylum_name = "Chordata", page = 1:2)

rl_check_api()

cranlogs::cran_downloads("redlist", when = "last-week")
