# [beh] Mediation outcome ~ cue * stim * expectrating * n-1outcomerating  {#ch17_mediation}


helpful resources
https://nmmichalak.github.io/nicholas_michalak/blog_entries/2018/nrg01/nrg01.html
## What is the purpose of this notebook? {.unlisted .unnumbered}
Here, I model the outcome ratings as a function of cue, stimulus intensity, expectation ratings, N-1 outcome rating. 
* As opposed to notebook 15, I want to check if the demeaning process should be for runs as opposed to subjects. 
* In other words, calculate the average within run and subtract ratings 
* Main model: `lmer(outcome_rating ~ cue * stim * expectation rating + N-1 outcomerating)` 
* Main question: What constitutes a reported outcome rating? 
* Sub questions:
  - If there is a linear relationship between expectation rating and outcome rating, does this differ as a function of cue?
  - How does a N-1 outcome rating affect current expectation ratings? 
  - Later, is this effect different across tasks or are they similar?

* IV: 
  stim (high / med / low)
  cue (high / low)
  expectation rating (continuous)
  N-1 outcome rating (continuous)
* DV: outcome rating

### Some thoughts, TODOs {.unlisted .unnumbered}

* Standardized coefficients
* Slope difference? Intercept difference? ( cue and expectantion rating)
* Correct for the range (within participant)
hypothesis:
1. Larger expectation leads to prediction error
2. Individual differences in ratings
3. Outcome experience, based on behavioral experience
What are the brain maps associated with each component.  




load data and combine participant data




```
##  event02_expect_RT event04_actual_RT event02_expect_angle event04_actual_angle
##  Min.   :0.6504    Min.   :0.0171    Min.   :  0.00       Min.   :  0.00      
##  1st Qu.:1.6200    1st Qu.:1.9188    1st Qu.: 29.55       1st Qu.: 37.83      
##  Median :2.0511    Median :2.3511    Median : 57.58       Median : 60.49      
##  Mean   :2.1337    Mean   :2.4011    Mean   : 61.88       Mean   : 65.47      
##  3rd Qu.:2.5589    3rd Qu.:2.8514    3rd Qu.: 88.61       3rd Qu.: 87.70      
##  Max.   :3.9912    Max.   :3.9930    Max.   :180.00       Max.   :180.00      
##  NA's   :651       NA's   :638       NA's   :651          NA's   :641
```



### Covariance matrix: ratings and RT {.unlisted .unnumbered}

```{=html}
<div class="plotly html-widget html-fill-item" id="htmlwidget-c0ab84f5f70e74717c6b" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c0ab84f5f70e74717c6b">{"x":{"visdat":{"27da667288a2":["function () ","plotlyVisDat"]},"cur_data":"27da667288a2","attrs":{"27da667288a2":{"z":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"heatmap","colors":["#590007","#590007","#5B0107","#5C0108","#5D0207","#5D0207","#5E0308","#5F0308","#600407","#610507","#620606","#620606","#630707","#640807","#650906","#660906","#670A07","#670B07","#680C06","#690C06","#6A0D06","#6B0D06","#6C0E07","#6C0F07","#6D1006","#6E1006","#6F1107","#701207","#711306","#721306","#731405","#731405","#741506","#751606","#761705","#771705","#781806","#791906","#7A1A05","#7B1A06","#7C1B06","#7D1C06","#7E1D05","#7E1D06","#7F1E06","#801E06","#822006","#832106","#842105","#852206","#862206","#872406","#882506","#892606","#8A2605","#8B2706","#8C2806","#8D2905","#8E2A05","#8F2B06","#902C06","#912D05","#932E05","#942F06","#953006","#963107","#973206","#983307","#993407","#9A3508","#9B3608","#9C3709","#9E3809","#9F390A","#A03B0A","#A13C0B","#A23D0C","#A33E0D","#A43F0E","#A5410F","#A6420F","#A74310","#A84411","#A94612","#AA4713","#AB4914","#AC4915","#AE4A16","#AE4B17","#AF4D19","#AF4E1A","#B1501C","#B2511D","#B2521E","#B3531F","#B4531F","#B55521","#B55622","#B65824","#B65925","#B75A26","#B75B27","#B85C28","#B95D29","#BA5E2A","#BA5F2C","#BB602D","#BB612E","#BC622F","#BC6330","#BD6431","#BD6432","#BE6533","#BD6635","#BE6736","#BE6837","#BF6938","#BF6A39","#C06B3A","#C06C3B","#C16D3C","#C16D3E","#C26E3F","#C16F40","#C27041","#C27142","#C37243","#C37344","#C47446","#C47447","#C57548","#C57649","#C6774A","#C5784B","#C67A4D","#C67A4E","#C77B50","#C87C51","#C87C51","#C97E53","#C87F54","#C98056","#C98157","#CA8258","#CA8259","#CB835A","#CB845B","#CC855D","#CB865E","#CC875F","#CC8860","#CD8961","#CD8A63","#CE8B64","#CE8B65","#CF8C66","#CE8D67","#CF8E68","#CF8F6A","#D0906B","#D0916C","#D1926D","#D1936F","#D29470","#D29471","#D39572","#D29673","#D39775","#D39876","#D49977","#D49A78","#D59B7A","#D59C7B","#D69D7C","#D59E7D","#D69F7F","#D69F80","#D7A081","#D7A182","#D8A284","#D8A385","#D9A486","#DAA688","#DAA789","#DBA88B","#DAA98C","#DBAA8D","#DBAB8E","#DCAC90","#DCAD91","#DDAE93","#DDAF94","#DEB095","#DEB196","#DFB298","#DEB399","#DFB49A","#DFB59B","#E0B69D","#E0B79F","#E1B8A0","#E1B9A1","#E2BAA2","#E2BBA4","#E3BCA5","#E3BDA7","#E4BEA8","#E3BEA9","#E4BFAA","#E4C0AC","#E5C1AE","#E5C3AF","#E6C4B0","#E6C5B1","#E7C6B2","#E7C7B4","#E8C8B6","#E8C9B7","#E9CAB8","#E8CBB9","#E9CCBB","#E9CDBC","#EACEBE","#EACFBF","#EBD0C1","#EBD0C2","#EBD1C3","#EBD3C5","#ECD4C6","#EDD5C8","#ECD6C9","#EDD7CB","#EDD8CC","#EED9CD","#EEDACE","#EDDBD0","#EDDCD1","#EEDDD3","#EEDDD4","#EEDED5","#EEDFD6","#EDE0D8","#EDE0D9","#EEE1DA","#EEE2DB","#EDE3DC","#EDE3DD","#ECE4DE","#ECE4DF","#EBE5E0","#EBE5E1","#EAE6E2","#EAE5E3","#E9E6E4","#E8E6E4","#E7E7E5","#E7E7E6","#E6E6E7","#E5E6E7","#E3E7E7","#E2E7E7","#E1E6E8","#E0E6E8","#DFE5E9","#DEE6E9","#DCE5E8","#DBE5E8","#D9E4E9","#D8E4E9","#D6E3E8","#D5E3E8","#D3E2E9","#D2E1E9","#D0E0E8","#CEDFE7","#CDDFE7","#CBDEE7","#CADDE7","#C8DCE6","#C7DBE6","#C5DAE5","#C4DAE5","#C2D9E4","#C1D8E4","#BFD7E3","#BED6E3","#BCD5E2","#BBD5E2","#B9D4E1","#B7D3E1","#B5D2E0","#B3D1DF","#B2D0DE","#B0CFDE","#AFCEDD","#ADCDDD","#ACCCDC","#AACBDC","#A9CADB","#A7C9DA","#A5C8D9","#A3C7D9","#A1C6D8","#A0C5D8","#9EC4D7","#9DC4D6","#9BC3D5","#9AC2D5","#98C1D4","#97C0D4","#95BFD3","#94BED2","#92BDD1","#90BCD1","#8EBBD0","#8DBAD0","#8BB9CF","#8AB8CE","#88B6CD","#86B5CC","#85B4CC","#83B3CB","#81B2CA","#7FB1C9","#7EB0C9","#7CAFC8","#7BAEC8","#79ADC7","#78ACC6","#76ABC5","#75AAC5","#73A9C4","#72A8C4","#70A7C3","#6EA6C2","#6CA5C1","#6AA4C1","#69A3C0","#67A2C0","#66A1BF","#64A0BE","#639FBD","#619EBD","#5F9DBC","#5D9CBB","#5B9BBA","#5A9ABA","#5999B9","#5798B9","#5597B8","#5496B7","#5295B6","#5194B6","#4F93B5","#4E92B4","#4C91B3","#4B90B3","#498EB2","#488DB2","#468BB1","#458BB0","#438AAF","#4289AF","#4087AE","#3E86AC","#3D85AC","#3B84AB","#3A83AB","#3882AA","#3781A9","#3580A8","#347FA8","#327EA7","#317DA6","#2F7CA5","#2E7BA5","#2C7AA4","#2B79A4","#2A78A3","#2977A2","#2776A1","#2575A1","#2474A0","#2373A0","#22729F","#20719E","#1F709D","#1E6F9D","#1D6E9C","#1C6D9C","#1B6C9B","#196B9A","#186A99","#176999","#166898","#156798","#146697","#136697","#126596","#116496","#106395","#106294","#0F6193","#0E6093","#0C5E92","#0C5E92","#0B5D91","#0B5D91","#0A5C90","#085A8F","#08598F","#07588E","#07578D","#06568C","#06568C","#05558B","#06548B","#05538A","#05528A","#045189","#055189","#045088","#044F88","#034E87","#034D87","#044C86","#044C86","#034B85","#034A85","#024984","#024984","#034883","#034783","#024682","#024582","#024481","#024481","#034380","#034280","#02417F","#02417F","#03407E","#033F7E","#023E7D","#023E7D","#033D7C","#033C7C","#023B7B","#023A7B","#01397A","#01397A","#023879","#023779","#013678","#013577","#023477","#013376","#013376","#023275","#023175","#013074","#013074","#022F73","#022E73","#012D72","#012D72","#022C71","#022B71","#012A70","#012A70","#02296F","#02286F","#01276E","#01276E","#02266D","#02256D","#02246C","#02236C","#01226B","#01226B","#02216A","#02206A","#011F69","#021F69","#011E68","#011D68","#021C67","#021C67","#011B66","#011A66","#001965","#001865","#011764","#011764","#001663","#001563","#011462","#011462","#001361","#001260"],"inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"zaxis":{"title":"cormat"}},"xaxis":{"domain":[0,1],"automargin":true,"tickmode":"array","tickvals":[0,1,2,3,4],"ticktext":["event04_actual_angle","event02_expect_angle","event01_cue_onset","event02_expect_RT","event04_actual_RT"],"gridcolor":"transparent","zerolinecolor":"transparent","title":"","zeroline":false,"showgrid":false},"yaxis":{"domain":[0,1],"automargin":true,"tickmode":"array","tickvals":[0,1,2,3,4],"ticktext":["event04_actual_angle","event02_expect_angle","event01_cue_onset","event02_expect_RT","event04_actual_RT"],"gridcolor":"transparent","zerolinecolor":"transparent","title":"","autorange":"reversed","zeroline":false,"showgrid":false},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5},"plot_bgcolor":"transparent","paper_bgcolor":"transparent"},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false,"displayModeBar":false},"data":[{"colorbar":{"title":"cormat","ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"colorscale":[["0","rgba(89,0,7,1)"],["0.0416666666666667","rgba(107,13,6,1)"],["0.0833333333333333","rgba(126,29,5,1)"],["0.125","rgba(147,46,5,1)"],["0.166666666666667","rgba(169,70,18,1)"],["0.208333333333333","rgba(186,94,42,1)"],["0.25","rgba(194,113,66,1)"],["0.291666666666667","rgba(203,132,91,1)"],["0.333333333333333","rgba(210,150,116,1)"],["0.375","rgba(219,171,142,1)"],["0.416666666666667","rgba(228,191,170,1)"],["0.458333333333333","rgba(237,213,199,1)"],["0.5","rgba(235,229,225,1)"],["0.541666666666667","rgba(212,227,232,1)"],["0.583333333333333","rgba(179,209,223,1)"],["0.625","rgba(146,189,209,1)"],["0.666666666666667","rgba(113,167,195,1)"],["0.708333333333333","rgba(79,147,181,1)"],["0.75","rgba(47,124,165,1)"],["0.791666666666667","rgba(21,103,152,1)"],["0.833333333333333","rgba(6,84,139,1)"],["0.875","rgba(3,67,128,1)"],["0.916666666666667","rgba(1,51,118,1)"],["0.958333333333333","rgba(1,34,107,1)"],["1","rgba(0,18,96,1)"]],"showscale":true,"z":[[1,0.62734921960762247,-0.12733126540763812,-0.038715816730490592,-0.15597630291158573],[0.62734921960762247,1,-0.094732639796961352,-0.053194395848554892,-0.12735368707113573],[-0.12733126540763812,-0.094732639796961352,1,0.087858734149391479,0.09477338992013444],[-0.038715816730490592,-0.053194395848554892,0.087858734149391479,1,0.2790896117901982],[-0.15597630291158573,-0.12735368707113573,0.09477338992013444,0.2790896117901982,1]],"type":"heatmap","xaxis":"x","yaxis":"y","frame":null,"zmin":-1,"zmax":1}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

### Covariance matrix: fixation durations (e.g. ISIs) {.unlisted .unnumbered}

```{=html}
<div class="plotly html-widget html-fill-item" id="htmlwidget-2a735f03a348b056090f" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-2a735f03a348b056090f">{"x":{"visdat":{"27da49ad1c3f":["function () ","plotlyVisDat"]},"cur_data":"27da49ad1c3f","attrs":{"27da49ad1c3f":{"z":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"heatmap","colors":["#590007","#590007","#5B0107","#5C0108","#5D0207","#5D0207","#5E0308","#5F0308","#600407","#610507","#620606","#620606","#630707","#640807","#650906","#660906","#670A07","#670B07","#680C06","#690C06","#6A0D06","#6B0D06","#6C0E07","#6C0F07","#6D1006","#6E1006","#6F1107","#701207","#711306","#721306","#731405","#731405","#741506","#751606","#761705","#771705","#781806","#791906","#7A1A05","#7B1A06","#7C1B06","#7D1C06","#7E1D05","#7E1D06","#7F1E06","#801E06","#822006","#832106","#842105","#852206","#862206","#872406","#882506","#892606","#8A2605","#8B2706","#8C2806","#8D2905","#8E2A05","#8F2B06","#902C06","#912D05","#932E05","#942F06","#953006","#963107","#973206","#983307","#993407","#9A3508","#9B3608","#9C3709","#9E3809","#9F390A","#A03B0A","#A13C0B","#A23D0C","#A33E0D","#A43F0E","#A5410F","#A6420F","#A74310","#A84411","#A94612","#AA4713","#AB4914","#AC4915","#AE4A16","#AE4B17","#AF4D19","#AF4E1A","#B1501C","#B2511D","#B2521E","#B3531F","#B4531F","#B55521","#B55622","#B65824","#B65925","#B75A26","#B75B27","#B85C28","#B95D29","#BA5E2A","#BA5F2C","#BB602D","#BB612E","#BC622F","#BC6330","#BD6431","#BD6432","#BE6533","#BD6635","#BE6736","#BE6837","#BF6938","#BF6A39","#C06B3A","#C06C3B","#C16D3C","#C16D3E","#C26E3F","#C16F40","#C27041","#C27142","#C37243","#C37344","#C47446","#C47447","#C57548","#C57649","#C6774A","#C5784B","#C67A4D","#C67A4E","#C77B50","#C87C51","#C87C51","#C97E53","#C87F54","#C98056","#C98157","#CA8258","#CA8259","#CB835A","#CB845B","#CC855D","#CB865E","#CC875F","#CC8860","#CD8961","#CD8A63","#CE8B64","#CE8B65","#CF8C66","#CE8D67","#CF8E68","#CF8F6A","#D0906B","#D0916C","#D1926D","#D1936F","#D29470","#D29471","#D39572","#D29673","#D39775","#D39876","#D49977","#D49A78","#D59B7A","#D59C7B","#D69D7C","#D59E7D","#D69F7F","#D69F80","#D7A081","#D7A182","#D8A284","#D8A385","#D9A486","#DAA688","#DAA789","#DBA88B","#DAA98C","#DBAA8D","#DBAB8E","#DCAC90","#DCAD91","#DDAE93","#DDAF94","#DEB095","#DEB196","#DFB298","#DEB399","#DFB49A","#DFB59B","#E0B69D","#E0B79F","#E1B8A0","#E1B9A1","#E2BAA2","#E2BBA4","#E3BCA5","#E3BDA7","#E4BEA8","#E3BEA9","#E4BFAA","#E4C0AC","#E5C1AE","#E5C3AF","#E6C4B0","#E6C5B1","#E7C6B2","#E7C7B4","#E8C8B6","#E8C9B7","#E9CAB8","#E8CBB9","#E9CCBB","#E9CDBC","#EACEBE","#EACFBF","#EBD0C1","#EBD0C2","#EBD1C3","#EBD3C5","#ECD4C6","#EDD5C8","#ECD6C9","#EDD7CB","#EDD8CC","#EED9CD","#EEDACE","#EDDBD0","#EDDCD1","#EEDDD3","#EEDDD4","#EEDED5","#EEDFD6","#EDE0D8","#EDE0D9","#EEE1DA","#EEE2DB","#EDE3DC","#EDE3DD","#ECE4DE","#ECE4DF","#EBE5E0","#EBE5E1","#EAE6E2","#EAE5E3","#E9E6E4","#E8E6E4","#E7E7E5","#E7E7E6","#E6E6E7","#E5E6E7","#E3E7E7","#E2E7E7","#E1E6E8","#E0E6E8","#DFE5E9","#DEE6E9","#DCE5E8","#DBE5E8","#D9E4E9","#D8E4E9","#D6E3E8","#D5E3E8","#D3E2E9","#D2E1E9","#D0E0E8","#CEDFE7","#CDDFE7","#CBDEE7","#CADDE7","#C8DCE6","#C7DBE6","#C5DAE5","#C4DAE5","#C2D9E4","#C1D8E4","#BFD7E3","#BED6E3","#BCD5E2","#BBD5E2","#B9D4E1","#B7D3E1","#B5D2E0","#B3D1DF","#B2D0DE","#B0CFDE","#AFCEDD","#ADCDDD","#ACCCDC","#AACBDC","#A9CADB","#A7C9DA","#A5C8D9","#A3C7D9","#A1C6D8","#A0C5D8","#9EC4D7","#9DC4D6","#9BC3D5","#9AC2D5","#98C1D4","#97C0D4","#95BFD3","#94BED2","#92BDD1","#90BCD1","#8EBBD0","#8DBAD0","#8BB9CF","#8AB8CE","#88B6CD","#86B5CC","#85B4CC","#83B3CB","#81B2CA","#7FB1C9","#7EB0C9","#7CAFC8","#7BAEC8","#79ADC7","#78ACC6","#76ABC5","#75AAC5","#73A9C4","#72A8C4","#70A7C3","#6EA6C2","#6CA5C1","#6AA4C1","#69A3C0","#67A2C0","#66A1BF","#64A0BE","#639FBD","#619EBD","#5F9DBC","#5D9CBB","#5B9BBA","#5A9ABA","#5999B9","#5798B9","#5597B8","#5496B7","#5295B6","#5194B6","#4F93B5","#4E92B4","#4C91B3","#4B90B3","#498EB2","#488DB2","#468BB1","#458BB0","#438AAF","#4289AF","#4087AE","#3E86AC","#3D85AC","#3B84AB","#3A83AB","#3882AA","#3781A9","#3580A8","#347FA8","#327EA7","#317DA6","#2F7CA5","#2E7BA5","#2C7AA4","#2B79A4","#2A78A3","#2977A2","#2776A1","#2575A1","#2474A0","#2373A0","#22729F","#20719E","#1F709D","#1E6F9D","#1D6E9C","#1C6D9C","#1B6C9B","#196B9A","#186A99","#176999","#166898","#156798","#146697","#136697","#126596","#116496","#106395","#106294","#0F6193","#0E6093","#0C5E92","#0C5E92","#0B5D91","#0B5D91","#0A5C90","#085A8F","#08598F","#07588E","#07578D","#06568C","#06568C","#05558B","#06548B","#05538A","#05528A","#045189","#055189","#045088","#044F88","#034E87","#034D87","#044C86","#044C86","#034B85","#034A85","#024984","#024984","#034883","#034783","#024682","#024582","#024481","#024481","#034380","#034280","#02417F","#02417F","#03407E","#033F7E","#023E7D","#023E7D","#033D7C","#033C7C","#023B7B","#023A7B","#01397A","#01397A","#023879","#023779","#013678","#013577","#023477","#013376","#013376","#023275","#023175","#013074","#013074","#022F73","#022E73","#012D72","#012D72","#022C71","#022B71","#012A70","#012A70","#02296F","#02286F","#01276E","#01276E","#02266D","#02256D","#02246C","#02236C","#01226B","#01226B","#02216A","#02206A","#011F69","#021F69","#011E68","#011D68","#021C67","#021C67","#011B66","#011A66","#001965","#001865","#011764","#011764","#001663","#001563","#011462","#011462","#001361","#001260"],"inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"zaxis":{"title":"cormat"}},"xaxis":{"domain":[0,1],"automargin":true,"tickmode":"array","tickvals":[0,1,2],"ticktext":["ISI02_duration","ISI01_duration","ISI03_duration"],"gridcolor":"transparent","zerolinecolor":"transparent","title":"","zeroline":false,"showgrid":false},"yaxis":{"domain":[0,1],"automargin":true,"tickmode":"array","tickvals":[0,1,2],"ticktext":["ISI02_duration","ISI01_duration","ISI03_duration"],"gridcolor":"transparent","zerolinecolor":"transparent","title":"","autorange":"reversed","zeroline":false,"showgrid":false},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5},"plot_bgcolor":"transparent","paper_bgcolor":"transparent"},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false,"displayModeBar":false},"data":[{"colorbar":{"title":"cormat","ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"colorscale":[["0","rgba(89,0,7,1)"],["0.0416666666666667","rgba(107,13,6,1)"],["0.0833333333333333","rgba(126,29,5,1)"],["0.125","rgba(147,46,5,1)"],["0.166666666666667","rgba(169,70,18,1)"],["0.208333333333333","rgba(186,94,42,1)"],["0.25","rgba(194,113,66,1)"],["0.291666666666667","rgba(203,132,91,1)"],["0.333333333333333","rgba(210,150,116,1)"],["0.375","rgba(219,171,142,1)"],["0.416666666666667","rgba(228,191,170,1)"],["0.458333333333333","rgba(237,213,199,1)"],["0.5","rgba(235,229,225,1)"],["0.541666666666667","rgba(212,227,232,1)"],["0.583333333333333","rgba(179,209,223,1)"],["0.625","rgba(146,189,209,1)"],["0.666666666666667","rgba(113,167,195,1)"],["0.708333333333333","rgba(79,147,181,1)"],["0.75","rgba(47,124,165,1)"],["0.791666666666667","rgba(21,103,152,1)"],["0.833333333333333","rgba(6,84,139,1)"],["0.875","rgba(3,67,128,1)"],["0.916666666666667","rgba(1,51,118,1)"],["0.958333333333333","rgba(1,34,107,1)"],["1","rgba(0,18,96,1)"]],"showscale":true,"z":[[1,0.10422759972680674,0.071212155444998371],[0.10422759972680674,1,-0.057678817016532574],[0.071212155444998371,-0.057678817016532574,1]],"type":"heatmap","xaxis":"x","yaxis":"y","frame":null,"zmin":-1,"zmax":1}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```





## mediation


```r
psych::mediate(event04_actual_angle ~ CUE_high_gt_low*stim_con_linear+ event02_expect_angle + lag.04outcomeangle, data = pvc, n.iter = 1000) %>% print(short = FALSE) 
```

<img src="17_mediation_cue-stim-expect_outcome_files/figure-html/unnamed-chunk-5-1.png" width="672" />

```
## 
## Mediation/Moderation Analysis 
## Call: psych::mediate(y = event04_actual_angle ~ CUE_high_gt_low * stim_con_linear + 
##     event02_expect_angle + lag.04outcomeangle, data = pvc, n.iter = 1000)
## 
## The DV (Y) was  event04_actual_angle . The IV (X) was  CUE_high_gt_low stim_con_linear event02_expect_angle lag.04outcomeangle CUE_high_gt_low*stim_con_linear . The mediating variable(s) =  .Call: psych::mediate(y = event04_actual_angle ~ CUE_high_gt_low * stim_con_linear + 
##     event02_expect_angle + lag.04outcomeangle, data = pvc, n.iter = 1000)
## 
## No mediator specified leads to traditional regression 
##                                 event04_actual_angle   se     t   df      Prob
## Intercept                                       0.00 0.30 -0.01 5023  9.89e-01
## CUE_high_gt_low                                -5.37 0.71 -7.54 5023  5.62e-14
## stim_con_linear                                34.42 0.75 46.13 5023  0.00e+00
## event02_expect_angle                            0.36 0.01 33.69 5023 1.84e-224
## lag.04outcomeangle                              0.48 0.01 46.08 5023  0.00e+00
## CUE_high_gt_low*stim_con_linear                 1.71 1.49  1.14 5023  2.53e-01
## 
## R = 0.83 R2 = 0.68   F = 2177.74 on 5 and 5023 DF   p-value:  0
```
## mediation 2

```r
mod1 <- "# a path
         #thirst ~ a * room_temp
         event02_expect_angle ~ a * CUE_high_gt_low

         # b path
         #consume ~ b * thirst
         event04_actual_angle ~ b* event02_expect_angle
         
         # c prime path 
         #consume ~ cp * room_temp
         event04_actual_angle ~ cp * CUE_high_gt_low
         
         # indirect and total effects
         ab := a * b
         total := cp + ab"
```


```r
library(lavaan)
```

```
## This is lavaan 0.6-17
## lavaan is FREE software! Please report any bugs.
```

```
## 
## Attaching package: 'lavaan'
```

```
## The following object is masked from 'package:psych':
## 
##     cor2cov
```

```r
fsem1 <- sem(mod1, data = pvc, se = "bootstrap", bootstrap = 1000)
```

```
## Warning in lav_model_nvcov_bootstrap(lavmodel = lavmodel, lavsamplestats =
## lavsamplestats, : lavaan WARNING: 256 bootstrap runs failed or did not
## converge.
```

```r
summary(fsem1, standardized = TRUE)
```

```
## lavaan 0.6.17 ended normally after 1 iteration
## 
##   Estimator                                         ML
##   Optimization method                           NLMINB
##   Number of model parameters                         5
## 
##                                                   Used       Total
##   Number of observations                          4621        5029
## 
## Model Test User Model:
##                                                       
##   Test statistic                                 0.000
##   Degrees of freedom                                 0
## 
## Parameter Estimates:
## 
##   Standard errors                            Bootstrap
##   Number of requested bootstrap draws             1000
##   Number of successful bootstrap draws             744
## 
## Regressions:
##                          Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##   event02_expect_angle ~                                                      
##     CUE_hgh__  (a)         34.622    1.059   32.695    0.000   34.622    0.429
##   event04_actual_angle ~                                                      
##     evnt02_x_  (b)          0.674    0.013   51.662    0.000    0.674    0.715
##     CUE_hgh__ (cp)        -15.034    0.943  -15.936    0.000  -15.034   -0.198
## 
## Variances:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##    .evnt02_xpct_ng 1328.872   32.424   40.984    0.000 1328.872    0.816
##    .evnt04_ctl_ngl  825.688   21.676   38.092    0.000  825.688    0.571
## 
## Defined Parameters:
##                    Estimate  Std.Err  z-value  P(>|z|)   Std.lv  Std.all
##     ab               23.321    0.854   27.311    0.000   23.321    0.307
##     total             8.287    1.153    7.188    0.000    8.287    0.109
```

```r
parameterestimates(fsem1, boot.ci.type = "bca.simple", standardized = TRUE) %>% 
  kable()
```



|lhs                  |op |rhs                  |label |          est|         se|          z| pvalue|     ci.lower|     ci.upper|       std.lv|    std.all|    std.nox|
|:--------------------|:--|:--------------------|:-----|------------:|----------:|----------:|------:|------------:|------------:|------------:|----------:|----------:|
|event02_expect_angle |~  |CUE_high_gt_low      |a     |   34.6222421|  1.0589323|  32.695425|      0|   32.5381074|   36.8315576|   34.6222421|  0.4289292|  0.8579540|
|event04_actual_angle |~  |event02_expect_angle |b     |    0.6735862|  0.0130382|  51.662357|      0|    0.6389107|    0.6943671|    0.6735862|  0.7148784|  0.7148784|
|event04_actual_angle |~  |CUE_high_gt_low      |cp    |  -15.0337345|  0.9433923| -15.935825|      0|  -16.8526515|  -13.2346722|  -15.0337345| -0.1976680| -0.3953800|
|event02_expect_angle |~~ |event02_expect_angle |      | 1328.8715236| 32.4239609|  40.984244|      0| 1258.5450975| 1388.0485222| 1328.8715236|  0.8160197|  0.8160197|
|event04_actual_angle |~~ |event04_actual_angle |      |  825.6875657| 21.6759152|  38.092397|      0|  784.8224538|  874.9438625|  825.6875657|  0.5710990|  0.5710990|
|CUE_high_gt_low      |~~ |CUE_high_gt_low      |      |    0.2499443|  0.0000000|         NA|     NA|    0.2499443|    0.2499443|    0.2499443|  1.0000000|  0.2499443|
|ab                   |:= |a*b                  |ab    |   23.3210633|  0.8539010|  27.311202|      0|   21.5371219|   25.0046717|   23.3210633|  0.3066322|  0.6133328|
|total                |:= |cp+ab                |total |    8.2873288|  1.1529270|   7.188078|      0|    6.0810341|   10.5875605|    8.2873288|  0.1089642|  0.2179528|



## mediation 3: Test same model using mediation() from MBESS

```
## Warning in resid.Y.on.X + resid.Y.on.M: longer object length is not a multiple
## of shorter object length
```

```
## Warning in resid.Y.on.X + resid.Y.on.M - resid.Y.on.X.and.M: longer object
## length is not a multiple of shorter object length
```

```
## Warning in standardized.resid.Y.on.X + standardized.resid.Y.on.M: longer object
## length is not a multiple of shorter object length
```

```
## Warning in standardized.resid.Y.on.X + standardized.resid.Y.on.M -
## standardized.resid.Y.on.X.and.M: longer object length is not a multiple of
## shorter object length
```

```
## Warning in abs(e.1M) + abs(e.1Y): longer object length is not a multiple of
## shorter object length
```

```
## Warning in abs(standardized.e.1M) + abs(standardized.e.1Y): longer object
## length is not a multiple of shorter object length
```

```
## [1] "Bootstrap resampling has begun. This process may take a considerable amount of time if the number of replications is large, which is optimal for the bootstrap procedure."
```

```
##                                           Estimate CI.Lower_BCa CI.Upper_BCa
## Indirect.Effect                        23.32106331           NA           NA
## Indirect.Effect.Partially.Standardized  0.61326642           NA           NA
## Index.of.Mediation                      0.30663221           NA           NA
## R2_4.5                                 -0.02001083           NA           NA
## R2_4.6                                  0.07764679           NA           NA
## R2_4.7                                  0.18103664           NA           NA
## Ratio.of.Indirect.to.Total.Effect       2.81406275           NA           NA
## Ratio.of.Indirect.to.Direct.Effect     -1.55124885           NA           NA
## Success.of.Surrogate.Endpoint           0.23936430           NA           NA
## Residual.Based_Gamma                            NA           NA           NA
## Residual.Based.Standardized_gamma               NA           NA           NA
## SOS                                    -1.68537707           NA           NA
```

## mediation 4: Test library mediation



