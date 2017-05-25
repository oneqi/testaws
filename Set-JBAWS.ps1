# AWS powershell

do {
	[int]$xMenuChoiceA = 0
	while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 6 )
	{		Write-host "1. Set Default AWS Credentials"
			Write-host "2. Check Which region you wish to use ( some regions may not have the resources you require ! )" 
			Write-Host "3. Create Virtual Private Cloud in default region"
			Write-host "4. Create Internet Gateway plus Public routing for the the VPC in task 3 ( best to use CIDR /16 so that this can be subnetted )"
			Write-host "5. Clear AWSCredentials "
			Write-host "6. Quit and Exit"
  			[Int]$xMenuChoiceA = read-host "Please enter an option 1 to 5..."
	}	

	Switch( $xMenuChoiceA ){
	
		1{Write-Host "Connecting to AWS" -Foreground "yellow"
			
			$storedCredentials = Get-AWSCredentials -ListProfileDetail
            if ($storedCredentials -eq $null) {

            Write-Warning "We need to create a default AWS credential profile where your login info can be stored .. "

            $AccessKey = Read-Host "Copy and paste your Access Key here .."
            $SecretKey = Read-Host "Copy and paste your secret key here .."            
           
            Initialize-AWSDefaults -AccessKey $AccessKey -SecretKey $SecretKey -Region  us-east-1
                                               }            
            Write-Warning "ProfileName is called 'default'"          

		 }
	
	
		2{Write-Host "Checking the regions available .. " -Foreground "yellow"
           
            Write-Warning "Check resources available per region ..https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services"
               
            Get-AWSRegion | ft * -AutoSize
                                        
            $Region = read-host "Enter the region you wish to use, e.g.us-east-1 .. please write as seen on screen under 'Region'"

            Initialize-AWSDefaults -ProfileName default -Region $Region

            Write-Warning "This is to clarify which is your default region"

            Get-DefaultAWSRegion | ft * -AutoSize
              
				 
	     }
	
	
	
		3{Write-Host "Creating Virtual Private Cloud (Network) in region from task number 2" -Foreground "yellow"
  
            $Block = read-host "Enter the network address plus CIDR you wish to use in QUOTES, e.g. '172.16.0.0/16' "
			$vpcResult = New-EC2Vpc	-CidrBlock $Block
            $vpcID = $vpcResult.vpcid

            Write-Output "VPCID; $vpcID"

            Edit-EC2VpcAttribute -VpcId $vpcID -EnableDnsSupport $true
            Edit-EC2VpcAttribute -VpcId $vpcID -EnableDnsHostnames $true

            Write-Warning "Also enabled DNS Support for Hostnames in VPC"

          
		 }


		4{Write-Host "Creating new Internet Gateway fror VPC in task number 3" -Foreground "yellow"

            Write-Warning "Creating an Internet Gateway plus ID"

            $IG = New-EC2InternetGateway
            $IGID = $IG.InternetGatewayId
            Write-Output “Internet Gateway ID : $IGID”
       
            Write-Warning "Attaching Internet Gateway to VPC in task 3"
            Add-EC2InternetGateway -InternetGatewayId $IGID -VpcId $vpcID

            Write-Warning "Creating new Route Table plus ID"
            $rtVPC = New-EC2RouteTable -VpcId $vpcID
            $rtID = $rtVPC.RouteTableId
            Write-Output “Route Table ID : $rtID”

            #Create new Route
            Write-Warning "Adding route to accept all traffic on public interface"
            $rPublic = New-EC2Route -RouteTableId $rtID -GatewayId $IGID -DestinationCidrBlock ‘0.0.0.0/0’

		 }

		5{Write-Host "Remove AWS credentials as set up in task 1" -Foreground "yellow"

            Remove-AWSCredentialProfile -ProfileName default

		 }

	}
} while ( $xMenuChoiceA -ne 6 )