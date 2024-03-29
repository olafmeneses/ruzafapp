# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # Dataframe adaptado para la visualización del mapa de calor
  rval_date <- reactive({
    date_df_eng %>%
      filter(between(dateObserved, 
                     as.Date(input$date_rg[1]),
                     ultimo_dia_mes(input$date_rg[2])))
  })
  
  # Filtrado de medida seleccionada
  rval_medida <- reactive({
    rval_date() %>%
      filter(medida == input$med)
  })
  
  # Generar dataframe para utilizar en el primer mapa de calor
  rval_df <- reactive({
    rval_medida() %>% 
      filter(street == input$calle)
  })
  
  # Generar dataframe para utilizar en el segundo mapa de calor
  rval_df2 <- reactive({
    rval_medida() %>% 
      filter(street == input$calle2)
  })
  
  # Renderizar el primer mapa de calor
  output$heatmap <- plotly::renderPlotly({
    p <- rval_df() %>% 
      date_heatmap() +
      labs(title = paste("Heat map for", nombres_calle[nombres_calle[1] == input$calle, 2]),
           fill=paste(input$med, "(dB)"))
    
    interactive_date_heatmap(p)
  })
  
  # Renderizar el segundo mapa de calor
  output$heatmap2 <- plotly::renderPlotly({
    p2 <- rval_df2() %>%
      date_heatmap() +
      labs(title = paste("Heat map for", nombres_calle[nombres_calle[1] == input$calle2, 2]),
           fill=paste(input$med, "(dB)"))
    
    interactive_date_heatmap(p2)
  })
  
  # Actualizar el selector del segundo sensor.
  # Quita la opción de escoger el mismo sensor que se ha escogido en el primer selector
  observe({
    updatePickerInput(session, "calle2",
                      label = "Select the second sensor",
                      choices = names(ids)[names(ids) != input$calle],
                      selected = input$calle2,
                      options = list(style = "btn-success")
    )
  })
  
  # Renderizar la visualización geográfica
  output$leaflet <- renderLeaflet({visualizacion_geografica()})
  
  # Renderizar la tabla con equivalencias de nombres abreviados de sensores
  output$nombres_calle <- renderTable({nombres_calle}, striped = T)
  
  # Caja de información para la visualización geográfica
  output$info.box <- renderText({info.box})
  
  # Renderizar la tabla con las escalas de ruido
  output$escala_ruido <- renderTable({escala_ruido}, striped = T)
})
