```{r setup2, include=FALSE}
setwd("../Recitations")
ei <- readxl::read_xlsx("NationalWmnEquality.xlsx")
wvstime <- WVS_TimeSeries_R_v1_5
wvstime <- wvstime[wvstime$S002 gss$happy, ]

wvstime[wvstime == -1] <- NA
wvstime[wvstime == -2] <- NA
wvstime[wvstime == -3] <- NA
wvstime[wvstime == -4] <- NA
wvstime[wvstime == -5] <- NA
wvstime[wvstime == -6] <- NA
wvstime[wvstime == -7] <- NA
wvstime[wvstime == -8] <- NA
wvstime[wvstime == -9] <- NA
wvstime[wvstime == -10] <- NA

```
