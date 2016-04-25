Function Create-PieChart() 
{
<#
This function relies on the Microsoft Chart Controls for Microsoft .NET Framework 3.5 and allows us to generate a graphical
 chart on the fly in our script and output it to a .PNG graphic file. So do make sure that the system that is running this 
 script has the Chart Controls installed (don’t worry, as it has a very small system footprint).
#>
       param([string]$FileName)
              
       [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
       [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
       
       #Create our chart object 
       $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
       $Chart.Width = 300
       $Chart.Height = 290 
       $Chart.Left = 10
       $Chart.Top = 10

       #Create a chartarea to draw on and add this to the chart 
       $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
       $Chart.ChartAreas.Add($ChartArea) 
       [void]$Chart.Series.Add("Data") 

       #Add a datapoint for each value specified in the arguments (args) 
    foreach ($value in $args[0]) {
              Write-Host "Now processing chart value: " + $value
              $datapoint = new-object System.Windows.Forms.DataVisualization.Charting.DataPoint(0, $value)
           $datapoint.AxisLabel = "Value" + "(" + $value + " GB)"
           $Chart.Series["Data"].Points.Add($datapoint)
       }

       $Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie
       $Chart.Series["Data"]["PieLabelStyle"] = "Outside" 
       $Chart.Series["Data"]["PieLineColor"] = "Black" 
       $Chart.Series["Data"]["PieDrawingStyle"] = "Concave" 
       ($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true

       #Set the title of the Chart to the current date and time 
       $Title = new-object System.Windows.Forms.DataVisualization.Charting.Title 
       $Chart.Titles.Add($Title) 
       $Chart.Titles[0].Text = "RAM Usage Chart (Used/Free)"

       #Save the chart to a file
       $Chart.SaveImage($FileName + ".png","png")
}