<#
.SYNOPSIS
    Quick command popup for WezTerm.
    Hotkey: LEADER + r (ALT+q then r)
    Shows a small dark-themed floating input box.
    Type command -> Enter -> popup closes -> runs in new terminal window.
#>

Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
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
            <TextBlock Text=">" Foreground="#E6B450" FontFamily="Cascadia Code, Consolas" FontSize="16" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,10,0"/>
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
$window = [Windows.Markup.XamlReader]::Load($reader)
$cmdBox = $window.FindName("cmdBox")

$window.Add_Loaded({ $cmdBox.Focus() })
$window.Add_KeyDown({ param($s,$e) if($e.Key -eq 'Escape'){$script:cmd=$null; $window.Close()} })
$cmdBox.Add_KeyDown({ param($s,$e) if($e.Key -eq 'Enter'){$script:cmd=$cmdBox.Text.Trim(); $window.Close()} })
$script:cmd = $null
$window.ShowDialog() | Out-Null

if ($script:cmd) {
    $scriptPath = Join-Path $env:TEMP "wezterm_quickcmd.ps1"
    Set-Content -Path $scriptPath -Value $script:cmd -Encoding UTF8
    Start-Process pwsh.exe -ArgumentList @(
        "-NoLogo", "-NoExit", "-Command", ". `"$scriptPath`""
    )
}
