# moq-to-nsubstitute-migrator

## What is it?

A standalone PowerShell script that can help migrate C# test projects from Moq to NSubstitute syntax by performing Regex-powered Find and Replace operations.

The Find and Replace patterns are embedded in the script file so that they can be added/amended in one place.

## Usage

The script can be executed as follows, with the argument after the filename referring to the directory where replacements should be made.

```powershell
./Migrate-MoqToNSubstitute.ps1 C:/<path_to_your_tests_project>
```

The script can also be executed without specifying a directory path, in which case it will perform replacements in the current script directory.

```powershell
./Migrate-MoqToNSubstitute.ps1
```

A confirmation prompt will be displayed before the script starts the migration process.

When running the script, the output displayed will be similar to the following.

```console
Moq will be replaced with NSubstitute in the following directory.

C:\<path_to_your_tests_project>

Do you want to proceed? (y/n): y

Replacing Moq in: C:\<path_to_your_tests_project>\UnitTest1.cs
Replacing Moq in: C:\<path_to_your_tests_project>\UnitTest2.cs
Replacing Moq in: C:\<path_to_your_tests_project>\UnitTest3.cs

Migration complete.
```
