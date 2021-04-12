#Credenciales de acceso
$user = "user@domain.com"
$password = ConvertTo-SecureString "password" -AsPlainText -Force 
$credential = New-Object System.Management.Automation.PSCredential ($user, $password)
Login-PowerBI -Credential $credential


if(-Not $args[0]){
	$PreviousDays = 0
}else{
	$PreviousDays = $args[0]
}

$dateTo=(get-date).AddDays(-$PreviousDays).ToString("yyyy-MM-ddT23:59:59")
$dateFrom=(get-date).AddDays(-$PreviousDays).ToString("yyyy-MM-ddT00:00:00")

$activities = Get-PowerBIActivityEvent -StartDateTime $dateFrom -EndDateTime $dateTo -ActivityType 'ViewReport' | ConvertFrom-Json

$path = "C:\path\"
$file="file.csv"
$filepath=$path+$file
$delimited = ";"
$head="`"UsuarioSFG`""+$delimited+"`"IdUsuarioSFG`""+$delimited+"`"Actividad`""+$delimited+"`"IdActividad`""+$delimited+"`"IP`""+$delimited+"`"Agente`""+$delimited+"`"Item`""+$delimited+"`"Workspace`""+$delimited+"`"IdWorkspace`""+$delimited+"`"DataSet`""+$delimited+"`"IdDataSet`""+$delimited+"`"Informe`""+$delimited+"`"IdInforme`""+$delimited+"`"Exito`""+$delimited+"`"MetodoConsumo`""+$delimited+"`"FechaRegistro`""

Set-Content -Path  $filepath -Value $head
Foreach ($activity in $activities)
{	
	$CreationTime = $activity.CreationTime  -replace "T", " " -replace "Z", ""
	$registro = "`""+$activity.UserId+"`"" `
				+ $delimited + "`""+$activity.UserKey+"`"" `
				+ $delimited + "`""+$activity.Activity+"`"" `
				+ $delimited + "`"{"+$activity.ActivityId+"}`"" `
				+ $delimited + "`""+$activity.ClientIP+"`"" `
				+ $delimited + "`""+$activity.UserAgent+"`"" `
				+ $delimited + "`""+$activity.ItemName+"`"" `
				+ $delimited + "`""+$activity.WorkSpaceName+"`"" `
				+ $delimited + "`"{"+$activity.WorkspaceId+"}`"" `
				+ $delimited + "`""+$activity.DatasetName+"`""	 `
				+ $delimited + "`"{"+$activity.DatasetId+"}`""	 `
				+ $delimited + "`""+$activity.ReportName+"`""	 `
				+ $delimited + "`"{"+$activity.ReportId+"}`""	 `
				+ $delimited + "`""+$activity.IsSuccess+"`""	  `
				+ $delimited + "`""+$activity.ConsumptionMethod+"`""	 `
				+ $delimited + "`""+$CreationTime+"`""		
	Add-Content -Path $filepath  -Value $registro
}