library(dplyr)
library(ggplot2)
library(tidyverse)
library(plotly)
library(rbokeh)

# load unemployment data
unemployment <- read.csv("data/unemployment.csv")

# select education col
education <- unemployment %>%
  select(Year, Month, 7:10)

# add date col
education <- education %>%
  mutate(date = as.Date(paste(Year, Month, "01", sep = "-"),
                        format = "%Y-%b-%d"))

# remove year and month col
education <- education %>%
  select(date, 3:6)

# rename cols so easier to read
education <- education %>%
  rename(
    Bachelor_Degree_or_Higher =
      Unemployment_Rate_25_Years_Over_Bachelor_s_Degree_and_Higher,
    High_School_Grad =
      Unemployment_Rate_25_Years_Over_High_School_Graduates_No_College,
    Some_High_School =
      Unemployment_Rate_25_Years_Over_Less_than_a_High_School_Diploma,
    Some_College_or_Associate_Degree =
      Unemployment_Rate_25_Years_Over_Some_College_or_Associate_Degree
  )

# reshape data so we can fit data into one graph
education <- education %>%
  gather(education_type, unemployment_rate, 2:5)

education <- education %>%
  filter(!is.na(unemployment_rate))

sapply(education, typeof)

# create buttons
chart_type <- list(
  x = 1.25,
  y = .7,
  buttons = list(
    list(
      method = "update",
      args = list(list("stackgroup" = "")),
      label = "Scatter"
    ),

    list(
      method = "update",
      args = list(list("stackgroup" = "one")),
      label = "Stackgroup"
    )
  )
)

hover <- list(
  x = 1.45,
  y = .7,
  buttons = list(
    list(
      method = "relayout",
      args = list(list("hovermode" = "closest")),
      label = "Hover off"
    ),
    list(
      method = "relayout",
      args = list(list("hovermode" = "x")),
      label = "Hover on "
    )
  )
)

# Create interactive plot with plotly
# symbol = ~education_type,
# fill = "tozeroy"
education_graph <- plot_ly(
  data = education,
  x = ~date,
  y = ~unemployment_rate,
  type = "scatter",
  alpha = .7,
  color = ~education_type,
  mode = "markers",
  text = ~ paste("Date: ", date, "<br>Unemployment Rate:", unemployment_rate,
                 "<br>education:", education_type),
  width=900, height=600
) %>%
  layout(
    title = "Unemployment Rate for 25 Years or Older",
    updatemenus = list(chart_type, hover),
    yaxis = list(title = "Unemployment Rate (%)"),
    xaxis = list(
      title = "Date",
      type = "date",
      range = c("2000-01-01", "2020-10-01"),
      rangeselector = list(
        buttons = list(
          list(
            count = 2,
            label = "2 yr",
            step = "year",
            stepmode = "backward"
          ),
          list(
            count = 5,
            label = "4 yr",
            step = "year",
            stepmode = "backward"
          ),
          list(
            count = 13,
            label = "12 yr",
            step = "year",
            stepmode = "backward"
          ),
          list(step = "all")
        )
      ),
      rangeslider = list(type = "date")
    )
  )
