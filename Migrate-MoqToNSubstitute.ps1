# Attempt to set the base directory from the first argument.
$baseDirectory = $args[0]

# If the base directory was not set, default it to the current script directory.
if (-not $baseDirectory) {
    $baseDirectory = Split-Path $MyInvocation.MyCommand.Path
}

Write-Host
Write-Host "Moq will be replaced with NSubstitute in the following directory.`n"
Write-Host "$baseDirectory`n"

# Ask the user for confirmation to proceed.
$confirmation = Read-Host "Do you want to proceed? (y/n)"

Write-Host

if ($confirmation -ne 'y') {
    Write-Host "Migration aborted.`n"
    exit
}

# Simple array for easy copy and pasting of Find and Replace patterns.
$findReplaceArray = @(
    'using Moq;', 'using NSubstitute;',
    'new Mock<(.+?)>\((.*?)\)', 'Substitute.For<$1>($2)',
    '\bMock<(.+?)>', '$1',
    '(?<!\.)\b(\w+)(\s\n\s*)?\.Setup(Get)?\((\w+) => \4(\.?.+?)\)(?=\.R|\s\n)', '$1$5',
    '\.Get<(.+?)>\(\)\.Setup\((\w+) => \2(\.?.+?)\)(?=\.R|\s\n)', '.Get<$1>()$3',
    '\.Get<(.+?)>\(\)\.SetupSequence?\((\w+) => \3(\.?.+?)\)(?=\.R|\s\n)', '.Get<$1>()$3',
    '(?<!\.)\b(\w+)(\s\n\s*)?\.SetupSequence?\((\w+) => \3(\.?.+?)\)(?=\.R|\s\n)', '$1$4',
    '\.Get<(.+?)>\(\)\.SetupSequence?\((\w+) => \2(\.?.+?)(\)(?!\)))', '.Get<$1>()$3',
    '(?<!\.)\b(\w+)\.Verify\((\w+) => \2(.+?), Times\.(Once(\(\))?|Exactly\((?<times>\d+)\))\)', '$1.Received(${times})$3',
    '(?<!\.)\b(\w+)\.Verify\((\w+) => \2(.+?), Times\.Never\)', '$1.DidNotReceive()$3',
    '(?<!\.)\b(\w+)(\s\n\s*)?\.Setup\(((\w+) => \4(\..?.+?)\))\)\s*\n*\.Throws', '$1.When($3).Throw',
    'It.IsAny', 'Arg.Any',
    'It.Is', 'Arg.Is',
    'MoqMockingKernel', 'NSubstituteMockingKernel',
    'using Ninject.MockingKernel.Moq;', 'using Ninject.MockingKernel.NSubstitute;',
    '\.GetMock<(.+?)>\(\)', '.Get<$1>()',
    '\.Object([\.,;)\s])', '$1',
    '\.Setup(Get)?\((\w+) => \2(\.?.+?)\)', '$3',
    '\.Returns\(\(\)\s=>\s', '.Returns(',
    'Mock.Of', 'Substitute.For',
    '\b(\w+)\.Verify\((\w+) => \w+\.([a-zA-Z0-9_]+)\((.*?)\)\);', '$1.Received().$3($4);'
    # Add more Find and Replace pairs here as needed.
)

# Convert the simple array to an array of custom objects for further processing.
$findReplaceItems = @()

for ($i = 0; $i -lt $findReplaceArray.Length; $i += 2) {
    $findReplaceItems += [PSCustomObject]@{
        Find    = $findReplaceArray[$i]
        Replace = $findReplaceArray[$i + 1]
    }
}

# Enumerate C# files and apply the replacements.
Get-ChildItem -Path $baseDirectory -Filter *.cs -Recurse | ForEach-Object {

    $fileName = $_.FullName

    # Skip generated files.
    if ($fileName -like "*.g.cs" -or $fileName -like "*AssemblyAttributes.cs") {
        return
    }

    $csFile = Get-Content -Path $fileName -Raw

    # Skip files that do not contain the text "Mock".
    if (-not $csFile.Contains("Mock")) {
        return
    }

    $csFileOriginalSize = $csFile.Length

    # Apply any required replacements.
    $findReplaceItems | ForEach-Object {
        $csFile = [Regex]::Replace($csFile, $_.Find, $_.Replace)
    }

    # If any replacments were made, update the file with the new contents.
    if ($csFile.Length -ne $csFileOriginalSize) {
        Write-Host "Replacing Moq in: $fileName"
        Set-Content -Path $fileName -Value $csFile
    }
}

Write-Host
Write-Host "Migration complete.`n"