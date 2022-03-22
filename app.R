library(shiny)
library(base64enc)
library(imager)


ui <- fluidPage(
  fileInput("myFile", "Upload image", accept = c("image/png", "image/jpg")),
  h2('Image uploaded:'),
  uiOutput("image"),
  
  h2('Palette:'),
  plotOutput("plotPalette"),
)

server <- function(input, output){
  # Copy image uploaded to www/
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile))
      return()
    file.copy(inFile$datapath, file.path("www", inFile$name) )
  })
  
  # Show image uploaded
  base64 <- reactive({
    inFile <- input[["myFile"]]
    if(!is.null(inFile)){
      dataURI(file = inFile$datapath, mime = "image/png")
    }
  })
  
  # Show image uploaded
  output[["image"]] <- renderUI({
    if(!is.null(base64())){
      tags$div(
        tags$img(src= base64(), width="100%"),
        style = "width: 400px;"
      )
    }
  })
  
  # Create palette
  output$plotPalette <- renderImage({
    # A temp file to save the output. It will be deleted after renderImage
    # sends it, because deleteFile=TRUE.
    outfile <- tempfile(fileext='.png')
    
    # Generate a png
    png(outfile, width=400, height=400)
    # El meollo 
    inFile <- input$myFile
    fPainting = load.image(inFile$datapath)
    #plot(fPainting)
    #2. Crear objecte
    dimension = dim(fPainting)
    #dimension: [1] 587(px) 330(px)   1(valor)   3(channel)
    paintingRGB <- data.frame(
      x = rep(1:dimension[2], each = dimension[1]),
      y = rep(dimension[1]:1, dimension[2]),
      R = as.vector(fPainting[,,1]), 
      G = as.vector(fPainting[,,2]),
      B = as.vector(fPainting[,,3])
    )
    #head(paintingRGB) 
    ##   x   y         R         G         B
    ## 1 1 551 0.9490196 0.8941176 0.8823529
    ## 2 1 550 0.9333333 0.8784314 0.8666667
    ## 3 1 549 0.9450980 0.9019608 0.8784314
    
    #Cluster. COMPROVAR EL NÚMERO ÒPTIM DE CLUSTERS (centers)
    k_means = kmeans(x = paintingRGB[,c("R","G","B")], centers = 12, iter.max = 20, nstart = 1);
    
    #Representació de la paleta
    rgbMatrix = k_means$centers;
    image(1:nrow(rgbMatrix), 1, as.matrix(1:nrow(rgbMatrix)), 
          col=rgb(rgbMatrix[,1], rgbMatrix[,2], rgbMatrix[,3]),
          xlab="", ylab = "", xaxt = "n", yaxt = "n", bty = "n")
    
    
    dev.off()
    
    # Return a list
    list(src = outfile,
         alt = "This is alternate text")
  }, deleteFile = FALSE)
}

shinyApp(ui, server)