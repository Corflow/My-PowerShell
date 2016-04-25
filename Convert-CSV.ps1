$csvs = Get-ChildItem .\* -Include *.csv
$y=$csvs.Count
Write-Host “Detected the following CSV files: ($y)”

    foreach ($csv in $csvs)
        {
        Write-Host ” “$csv.Name
        }

$outputfilename = read-host “Please enter the output file name: ”
Write-Host Creating: $outputfilename
$excelapp = new-object -comobject Excel.Application
$excelapp.sheetsInNewWorkbook = $csvs.Count
$xlsx = $excelapp.Workbooks.Add()
$sheet=1

    foreach ($csv in $csvs)
        {
        $row=1
        $column=1
        $worksheet = $xlsx.Worksheets.Item($sheet)
        $worksheet.Name = $csv.Name
        $file = (Get-Content $csv)
            foreach($line in $file)
                {
                $linecontents=$line -split ‘,(?!\s*\w+”)’

            foreach($cell in $linecontents)
                {
                $worksheet.Cells.Item($row,$column) = $cell
                $column++
                }
                $column=1
                $row++
                }
        $sheet++
        }

$xlsx.SaveAs($outputfilename)
$excelapp.quit()