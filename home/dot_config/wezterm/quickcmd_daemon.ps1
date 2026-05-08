Add-Type -AssemblyName PresentationFramework

$showEvent = New-Object System.Threading.EventWaitHandle(
    $false, [System.Threading.EventResetMode]::AutoReset, "QuickCmdShow")
$readyEvent = New-Object System.Threading.EventWaitHandle(
    $false, [System.Threading.EventResetMode]::ManualReset, "QuickCmdReady")
$readyEvent.Set()

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="QuickCmd"
        Width="600" Height="50"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen">
    <Border CornerRadius="8" Background="#0A0E14" BorderBrush="#2D2D2D" BorderThickness="1">
        <Border.Effect>
            <DropShadowEffect BlurRadius="20" ShadowDepth="4" Color="#000" Opacity="0.5"/>
        </Border.Effect>
        <DockPanel Margin="16,0,16,0">
            <TextBlock Text=">" FontWeight="Bold" Foreground="#E6B450" FontFamily="Cascadia Code, Consolas" FontSize="16" VerticalAlignment="Center" Margin="0,0,10,0"/>
            <TextBox x:Name="cmdBox"
                     Background="Transparent"
                     Foreground="#B3B1AD"
                     CaretBrush="#B3B1AD"
                     FontFamily="Cascadia Code, Consolas"
                     FontSize="14"
                     BorderThickness="0"
                     Padding="0"
                     VerticalAlignment="Center"
                     VerticalContentAlignment="Center"/>
        </DockPanel>
    </Border>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)

function Show-QuickCmdPopup {
    $reader.Position = 0
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $box = $window.FindName("cmdBox")
    $window.Add_Loaded({ $box.Focus() })
    $window.Add_KeyDown({ param($s,$e) if($e.Key -eq 'Escape'){$window.Close()} })
    $script:cmd = $null
    $box.Add_KeyDown({ param($s,$e)
        if ($e.Key -eq 'Enter') {
            $script:cmd = $box.Text.Trim()
            $window.Close()
        }
    })
    $window.ShowDialog() | Out-Null
    $script:cmd
}

while ($true) {
    $showEvent.WaitOne() | Out-Null
    $cmd = Show-QuickCmdPopup
    if ($cmd) {
        $scriptPath = Join-Path $env:TEMP "wezterm_quickcmd.ps1"
        Set-Content -Path $scriptPath -Value $cmd -Encoding UTF8
        Start-Process pwsh.exe -ArgumentList @(
            "-NoLogo", "-NoExit", "-Command", ". `"$scriptPath`""
        ) -WindowStyle Minimized
    }
}
