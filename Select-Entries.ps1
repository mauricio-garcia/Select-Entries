#Generalized script to generate a gui selector box from a csv file
#Input is a csv file with column headers
#User is prompted with a list of column headers.
#Output is the content of the selected columns, ordered and sorted unique. 

function Select-Entries {
    # Multiple selection prompt 
    # Gets user input and will then generate a list of data 
    # List is sorted alphanumerically and each entry is unique
    #generate hash table from $datapath file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$datapath,
        [Parameter(Position=1,Mandatory=$false)]
        [string]$formtitle="Select Entries"
    )  
    
    $entrydata = getEntriesFromCSV $datapath
    
    #region GUI form 
    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object System.Windows.Forms.Form
    $Form.width = 250
    $Form.height = 400
    $Form.Text = $formtitle
    $checkedlistbox=New-Object System.Windows.Forms.CheckedListBox
    $checkedlistbox.Location = '10,10'
    $checkedlistbox.Size = '200,250'
    $form.Controls.Add($checkedlistbox)
    
    #User Options
    $EntryOptions = $entrydata.keys
    $checkedListBox.DataSource = [collections.arraylist]$EntryOptions
    $checkedListBox.DisplayMember = 'Name'
    $checkedlistbox.CheckOnClick = $true
    
    #$checkedlistbox.Sorted = $true # causes an error 
    $ApplyButton = new-object System.Windows.Forms.Button
    $ApplyButton.Location = '120, 300'
    $ApplyButton.Size = '100, 40'
    $ApplyButton.Text = 'OK'
    $ApplyButton.DialogResult = 'Ok'
    $form.Controls.Add($ApplyButton)
    [void]$Form.ShowDialog()       
    $choices = $checkedlistbox.CheckedItems
    #endregion user input gui                  
    $choiceList = $null
    $choices | ForEach-Object {$choiceList += $entrydata[$_] } 
    Write-Output ($choiceList | Sort-Object | Get-Unique)
}

function getEntriesFromCSV {
    #Gets Entries list from a csv file
     Param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$datapath     
     )

    $mydata = Get-Content $datapath
    $mycsvdata  = Import-Csv $datapath
    # Convert column names into an array
    $headers = @($mydata[0].Split(","))
    #create hash tables from csv
    $datahash = [ordered]@{}
    $headers | ForEach-Object {$datahash += @{$_ = $mycsvdata.$_ -replace ",{2,}","" }}
    Write-Output $datahash
}
