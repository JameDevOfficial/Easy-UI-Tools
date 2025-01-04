local Selection = game:GetService("Selection")
local CHS = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local recordings = {}
local UserInputService = game:GetService("UserInputService")

--Settings
local DEBUG_MODE = false
local GLOBAL_KEY_RUN = 12 --Testing Purpose only, public key is 6! --last used key before release: 10
if GLOBAL_KEY_RUN ~= 6 then warn("GLOBAL_KEY_RUN is not the standard key! Change before public release!") end
local Waypoints = true --Set to true if you want to make it so the latest change gets undid when the undo buttons are pressed. (CTRL+Z)
local WaypointText = "EasyUITools" --Must enable Waypoints for this to be available.

local Description1 = "Easy UI Tools" --Put whatever you like in the string
local Description2 = "These are some UI Tools to make editing UI easier" --Put whatever you like in the string
local PluginIconURL = "rbxassetid://15244944010" --Icon URL

local marketplace = game:GetService("MarketplaceService")
local pluginId = 17386354664 --Change to plugin's ID.
local pluginVersion = "1.0.4" --Current plugin's version.

local excludedNames = {"Title"} --Objects with no ToolTip
local excludedParentNames = {"NotListed"} --Objects with these Parents have no ToolTip 
local checkParents = 4 --How many Parents should be checked for ToolTip 

--CHS Handler
CHS.OnRecordingStarted:Connect(function(name, displayName, identifier)
	table.insert(recordings, {
		identifier = identifier,
		name = name,
		startTime = os.time()
	})
	print("Recording started:", identifier, name, displayName)
end)


CHS.OnRecordingFinished:Connect(function(name, displayName, identifier, operation, finalOptions)
	for i, recording in pairs(recordings) do
		if recording.identifier == identifier then
			table.remove(recordings, i)
			print("Recording finished:", identifier, name, displayName)
			break
		end
	end
end)

-- Function to output the whole table
local function printRecordingsTable()
	if #recordings == 0 then
		return
	end
	print("--------------------------------------------------------------------------------")
	warn("Unfinished Recording, restart Studio if this Problem continues to exist.")
	print("This may occured after a previous error that prevented the recording to finish.")
	print("The System will try to auto-delete the unfinished Recording.")
	print("Current Recordings Table:")
	for i, recording in ipairs(recordings) do
		print(i, "Identifier:", recording.identifier, "Name:", recording.name)
	end
	print("Total recordings:", #recordings)
	print("--------------------------------------------------------------------------------")
end

local function clearOldRecordings()
	local currentTime = os.time()
	local newRecordings = {}

	for _, recording in ipairs(recordings) do
		if currentTime - recording.startTime <= 5 then
			table.insert(newRecordings, recording)
		else
			if CHS:IsRecordingInProgress(recording.identifier) then
				local success, errorMessage = pcall(function()
					CHS:FinishRecording(recording.identifier, Enum.FinishRecordingOperation.Cancel)
				end)
				if success then
					warn("Removed recording:", recording.identifier, recording.name)
				else
					warn("Failed to remove recording:", recording.identifier, recording.name, "Error:", errorMessage)
					print("Please restart Roblox Studio now. If this issue persists, report it to the forum for this plugin on the Devforum.")
					print("Easy UI Tools - JameDev")
					return
				end
			else
				warn("Recording already finished:", recording.identifier, recording.name)
			end
		end
	end

	recordings = newRecordings
end





--Create Plugin
local toolbar = plugin:CreateToolbar("Plugins by Jame")
local toolbarButton = toolbar:CreateButton(Description1, Description2, PluginIconURL)
toolbarButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- Widget will be initialized in floating panel
	false,   -- Widget will be initially enabled
	false,  -- Don't override the previous enabled state
	375,    -- Default width of the floating window
	960,    -- Default height of the floating window
	375,    -- Minimum width of the floating window
	960     -- Minimum height of the floating window
)


local UpdateLogModule = require(script.UpdateLogModule)
local ShowUpdateLog = false
local ShowHints = false
local Enabled = false
local widget = plugin:CreateDockWidgetPluginGui("ImportBasicLayout", widgetInfo)
widget.Name = "Easy UI Tools"
local GlobalWidget

local AccentColorKey = `AccentColorKey${GLOBAL_KEY_RUN}`
local FontFaceKey = `FontFaceKey${GLOBAL_KEY_RUN}`
local StrokeThicknessKey = `StrokeThicknessKey${GLOBAL_KEY_RUN}`
local BorderRadiusKey = `BorderRadiusKey${GLOBAL_KEY_RUN}`
local ToolTipShowKey = `ToolTipShowKey${GLOBAL_KEY_RUN}`
local UIScaleSizeKey = `UIScaleSizeKey${GLOBAL_KEY_RUN}`
local LastVersionUsedKey = `LastVersionUsed${GLOBAL_KEY_RUN}`
local PluginScaleKey = `PluginScaleKey${GLOBAL_KEY_RUN}`

-- Preferences Setup
if plugin:GetSetting(LastVersionUsedKey) == nil then
	ShowHints = true
	ShowUpdateLog = true
elseif tostring(plugin:GetSetting(LastVersionUsedKey)) ~= pluginVersion then
	ShowUpdateLog = true
end

local GlobalFontFace = "SourceSans"
if plugin:GetSetting(FontFaceKey) ~= nil then
	GlobalFontFace = Font.fromName(plugin:GetSetting(FontFaceKey))
end

local GlobalPluginScale = 1
if plugin:GetSetting(StrokeThicknessKey) ~= nil then
	GlobalPluginScale = tonumber(plugin:GetSetting(StrokeThicknessKey))
end


local GlobalStrokeThickness = 3
if plugin:GetSetting(StrokeThicknessKey) ~= nil then
	GlobalStrokeThickness = tonumber(plugin:GetSetting(StrokeThicknessKey))
end

local GlobalBorderRadius = 0.2
if plugin:GetSetting(BorderRadiusKey) ~= nil then
	GlobalStrokeThickness = tonumber(plugin:GetSetting(BorderRadiusKey))
end

local GlobalToolTipShow = true
if plugin:GetSetting(ToolTipShowKey) ~= nil then
	GlobalToolTipShow = plugin:GetSetting(ToolTipShowKey)
end

local GlobalUIScaleSize = 1.2
if plugin:GetSetting(UIScaleSizeKey) ~= nil then
	GlobalUIScaleSize = tonumber(plugin:GetSetting(UIScaleSizeKey))
end

local GlobalAccentColor = "#3c3c3c"
if plugin:GetSetting(AccentColorKey) ~= nil then
	GlobalAccentColor = tostring(plugin:GetSetting(AccentColorKey))
end

local function PrintStoreValues()
	if DEBUG_MODE then
		warn("All Keys with their values:")
		print("AccentColor: ", GlobalAccentColor, type(GlobalAccentColor))
		print("FontFace: ", GlobalFontFace, type(GlobalFontFace))
		print("StrokeThickness: ", GlobalStrokeThickness, type(GlobalStrokeThickness))
		print("BorderRadius: ", GlobalBorderRadius, type(GlobalBorderRadius))
		print("ToolTipShow: ", GlobalToolTipShow, type(GlobalToolTipShow))
		print("UIScale: ", GlobalUIScaleSize, type(GlobalUIScaleSize))
		print("LastVersionUsed: ", plugin:GetSetting(LastVersionUsedKey), type(plugin:GetSetting(LastVersionUsedKey)))
		print("PluginScale: ", GlobalPluginScale, type(GlobalPluginScale))
	end
end

if DEBUG_MODE == true then
	task.spawn(function()
		while true do
			task.wait(10)
			PrintStoreValues()
			--printRecordingsTable()
			--clearOldRecordings()
		end
	end)
end

--Tool Tip Check Functions
local function tableContains(tbl, value)
	for _, v in pairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

local function checkParentNames(obj, excludedNames)
	local current = obj
	for i = 1, checkParents do
		if not current or not current.Parent then
			return false
		end
		current = current.Parent
		if tableContains(excludedNames, current.Name) then
			return true
		end
	end
	return false
end
------------------------------------------------------------------------------

local recordingNum = 1

-- Widget for BasicLayoutUI
local function ImportBasicLayoutButtonClicked()

	if Waypoints == true then
		CHS:SetWaypoint(WaypointText) 

		-- Create new widget GUI
		GlobalWidget = widget
		local testWidget = GlobalWidget
		testWidget.Title = "JameDev's UI Tools" 

		-- Widget Contains --
		local UI = script.Main
		UI.Parent = widget
		UI.Version.Text = "v"..pluginVersion
		local MainScroll = UI.MainScroll
		local ImportUI = UI.ImportScroll
		local AnchorUI = UI.AnchorScroll
		local ZIndexUI = UI.ZIndexScroll
		
		-- ShowUpdateLog
		if ShowUpdateLog then
			UI.MainScroll.Visible = false
			local entryTemplate = UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.ContentFrame.Template
			UI.NotListed.UpdateLogPopUp.Visible = true
			UI.NotListed.UpdateLogPopUp.InfoBox.VersionText.Text = "Version: v"..pluginVersion

			local currentVersionLog = UpdateLogModule.log[pluginVersion]
			if currentVersionLog then
				for _, updateEntry in ipairs(currentVersionLog) do
					local newEntry = entryTemplate:Clone()
					newEntry.Text = "• "..updateEntry
					newEntry.Name = "Entry"
					newEntry.Visible = true
					newEntry.Parent = UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.ContentFrame
				end
			end
			
			local function compareVersions(a, b)
				local function parseVersion(str)
					local major, minor, patch = string.match(str, "(%d+)%.(%d+)%.(%d+)")
					if major and minor and patch then
						return tonumber(major) * 1000000 + tonumber(minor) * 1000 + tonumber(patch)
					end
					return 0  -- Return 0 for invalid version strings
				end

				return parseVersion(a) > parseVersion(b)
			end

			UI.NotListed.UpdateLogPopUp.InfoBox.UpdateHistory.MouseButton1Click:Connect(function()
				local contentFrame = UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.ContentFrame
				for _, child in pairs(contentFrame:GetChildren()) do
					if child:IsA("TextLabel") and child.Name ~= "Template" then
						child:Destroy()
					end
				end
				
				local sortedVersions = {}
				for version in pairs(UpdateLogModule.log) do
					table.insert(sortedVersions, version)
				end
				table.sort(sortedVersions, compareVersions)

				local entryTemplate = contentFrame.Template
				for _, version in ipairs(sortedVersions) do
					local versionHeader = entryTemplate:Clone()
					versionHeader.Text = "Version " .. version
					versionHeader.Font = Enum.Font.SourceSansBold
					versionHeader.Visible = true
					versionHeader.Parent = contentFrame
					versionHeader.Name = "VersionHeader"

					for _, updateEntry in ipairs(UpdateLogModule.log[version]) do
						local newEntry = entryTemplate:Clone()
						newEntry.Text = "• " .. updateEntry
						newEntry.Visible = true
						newEntry.Parent = contentFrame
						newEntry.Name = "Entry"
					end
				end

				UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.AutomaticSize = Enum.AutomaticSize.None
				UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.ContentFrame.AutomaticSize = Enum.AutomaticSize.None
				UI.NotListed.UpdateLogPopUp.InfoBox.OuterContent.Size = UDim2.new(1,0,0.6,0)
			end)

			UI.NotListed.UpdateLogPopUp.InfoBox.ConfirmButton.MouseButton1Click:Connect(function()
				UI.MainScroll.Visible = true
				UI.NotListed.UpdateLogPopUp.Visible = false
				plugin:SetSetting(LastVersionUsedKey, pluginVersion)
				if ShowHints then
					UI.NotListed.DarkBackground.Visible = true
					UI.NotListed.DarkBackground.BackgroundTransparency = 0.5
					UI.NotListed.DarkBackground.Size = UDim2.new(1,0,0.96,0)
					UI.NotListed.PreferencesHintLabel.Visible = true
				end
			end)
		end

		--ToolTip
		local ToolTip = UI.NotListed.ToolTip
		local ToolTipText = ToolTip.ToolTip
		local MouseIn = false
		local warningShown = false
		for i, v in ipairs(UI:GetDescendants()) do
			if v:IsA("TextButton") and not tableContains(excludedNames, v.Name) and not checkParentNames(v, excludedParentNames) then				v.MouseEnter:Connect(function()
					if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

					if GlobalToolTipShow == true then --and WindowFocused ==true
						MouseIn = true
						ToolTip.Visible = true
						ToolTipText.Text = "No Information available"

						-- Custom ToolTip Text
						-- Quick Actions

						if v.Name== "ScaleUI" then -- Fast Scale
							ToolTipText.Text = "Changes the size and position to scale instead of offset"
						elseif v.Name == "AddConstraint" then
							ToolTipText.Text = "Adds a constraint to keep the ratio between the X and Y Scale"
						elseif v.Name == "FitParent" then
							ToolTipText.Text = "Changes the size to fit the parent (1,0,1,0)"
						elseif v.Name == "RoundCorner" then
							ToolTipText.Text = "Add rounded corners (Border Radius Preference)"
						elseif v.Name == "SquareShape" then
							ToolTipText.Text = "Add a ratio, that makes the element squared"
						elseif v.Name == "TransparentBack" then
							ToolTipText.Text = "Make the background transparent"
						elseif v.Name == "SmartUIScale" then
							ToolTipText.Text = "Add a UIScale and keep the element centered"
						elseif v.Name == "SortNames" then
							ToolTipText.Text = "Add a increasing Number to selected elements"
							
							-- Quick Positions
						elseif v.Name == "TopLeft" then
							ToolTipText.Text = "Top Left"
						elseif v.Name == "TopCenter" then
							ToolTipText.Text = "Top Center"
						elseif v.Name == "TopRight" then
							ToolTipText.Text = "Top Right"
						elseif v.Name == "MiddleLeft" then
							ToolTipText.Text = "Middle Left"
						elseif v.Name == "MiddleCenter" then
							ToolTipText.Text = "Middle Center"
						elseif v.Name == "MiddleRight" then
							ToolTipText.Text = "Middle Right"
						elseif v.Name == "BottomLeft" then
							ToolTipText.Text = "Bottom Left"
						elseif v.Name == "BottomCenter" then
							ToolTipText.Text = "Bottom Center"
						elseif v.Name == "BottomRight" then
							ToolTipText.Text = "Bottom Right"

							-- Quick Text
						elseif v.Name == "AddStroke" then
							ToolTipText.Text = "Add a stroke to your Text (Stroke Thickness preference)"
						elseif v.Name == "DarkTheme" then
							ToolTipText.Text = "White text, dark background, apply FontFace preference"
						elseif v.Name == "LightTheme" then
							ToolTipText.Text = "Black text, white background, apply FontFace preference"
						elseif v.Name == "Scaled" then
							ToolTipText.Text = "Activate scaled text"

							-- Insert UI
						elseif v.Name == "Simple" then
							ToolTipText.Text = "Insert a simple UI Layout"
						elseif v.Name == "Extended" then
							ToolTipText.Text = "Insert a extended UI Layout"
						elseif v.Name =="Element_Frame" then
							ToolTipText.Text = "Insert a frame"
						elseif v.Name == "Element_TextButton" then
							ToolTipText.Text = "Insert a text button"
						elseif v.Name == "Element_TextLabel" then
							ToolTipText.Text = "Insert a text label"
						elseif v.Name == "Element_TextBox" then
							ToolTipText.Text = "Insert a text box"
						elseif v.Name == "Element_ImageButton" then
							ToolTipText.Text = "Insert a image button"
						elseif v.Name == "Element_ImageLabel" then
							ToolTipText.Text = "Insert a image label"
						elseif v.Name == "Element_ScrollingFrame" then
							ToolTipText.Text = "Insert a scrolling frame"
						elseif v.Name == "Element_VideoFrame" then
							ToolTipText.Text = "Insert a image video frame"
						elseif v.Name == "Element_ViewportFrame" then
							ToolTipText.Text = "Insert a viewport frame"

							-- Top Buttons
						elseif v.Name == "ImportUI" then
							ToolTipText.Text = "Options for inserting UI elements and layouts"
						elseif v.Name == "AnchorUI" then
							ToolTipText.Text = "Position option for selected UI elements"
						end
					end


					MouseIn = true
					-- Position ToolTip
					local frame = ToolTip  -- Get the reference to the frame object
					while MouseIn == true do
						local mouseWidgetPosition = widget:GetRelativeMousePosition();
						local viewportSize = workspace.CurrentCamera.ViewportSize
						ToolTip.Position = UDim2.new(0, mouseWidgetPosition.X, 0, mouseWidgetPosition.Y)
						task.wait()
					end
					MouseIn = true
				end)
				v.MouseLeave:Connect(function()
					MouseIn = false
					ToolTip.Visible = false
				end)
			end
		end

		-------------Version Control
		local MarketplaceService = game:GetService("MarketplaceService")
		local pluginId = 17386354664 -- Replace with your plugin's ID
		local currentVersion = pluginVersion -- Current version of your plugin

		local function parseVersion(description)
			local versionPattern = "v(%d+%.%d+%.%d+)"
			return description:match(versionPattern)
		end

		local function compareVersions(v1, v2)
			local v1Parts = {v1:match("(%d+)%.(%d+)%.(%d+)")}
			local v2Parts = {v2:match("(%d+)%.(%d+)%.(%d+)")}

			for i = 1, 3 do
				local v1Part, v2Part = tonumber(v1Parts[i]), tonumber(v2Parts[i])
				if v1Part > v2Part then return 1
				elseif v1Part < v2Part then return -1 end
			end
			return 0
		end
		local confirmedUpdate = false
		local function checkForUpdate()
			local success, productInfo = pcall(function()
				return MarketplaceService:GetProductInfo(pluginId)
			end)
			if not confirmedUpdate then
				if success and productInfo then
					local latestVersion = parseVersion(productInfo.Description)
					if latestVersion then
						if compareVersions(latestVersion, currentVersion) > 0 then
							print("New version available: " .. latestVersion)
							UI.NotListed.NewVersionPopUp.Visible = true
							UI.NotListed.NewVersionPopUp.InfoBox.VersionsFrame.NewVersion.Text = "New Version: v"..tostring(latestVersion)..""
							UI.NotListed.NewVersionPopUp.InfoBox.VersionsFrame.CurrentVersion.Text = "Current Version: v"..tostring(currentVersion)..""
							UI.NotListed.NewVersionPopUp.InfoBox.ConfirmButton.MouseButton1Click:Connect(function()
								confirmedUpdate = true
								UI.NotListed.NewVersionPopUp.Visible = false
								UI.Hint.Visible = true
							end)
						else 
							UI.NotListed.NewVersionPopUp.Visible = false
						end
					else
						warn("Failed to parse version from description")
					end
				else
					warn("Failed to fetch plugin information")
				end
			end
		end
		checkForUpdate()
		task.spawn(function()
			while task.wait(600) do -- Check every 10 minutes
				checkForUpdate()
			end
		end)
		
		--Update Plugin Scale--
		local function ScalePlugin()
			for i, v in ipairs(UI:GetDescendants()) do
				if v:IsA("UIGridLayout") then
					if not v:GetAttribute("StandardSize") then
						v:SetAttribute("StandardSize", v.CellSize)
					end
					print(v.Name, ": ", v.CellSize)
					v.CellSize = UDim2.new(
						UDim.new(v:GetAttribute("StandardSize").X.Scale * GlobalPluginScale, v:GetAttribute("StandardSize").X.Offset * GlobalPluginScale),
						UDim.new(v:GetAttribute("StandardSize").Y.Scale * GlobalPluginScale, v:GetAttribute("StandardSize").Y.Offset * GlobalPluginScale)
					)
					print(v.Name, ": ", v.CellSize)
				end
				if v.Name == "Title" and v:IsA("TextButton") then
					if not v:GetAttribute("StandardSize") then
						v:SetAttribute("StandardSize", v.Size)
					end
					print(v.Name, ": ", v.Size)
					v.Size = UDim2.new(
						v.Size.X.Scale,
						v.Size.X.Offset,
						v:GetAttribute("StandardSize").Y.Scale * GlobalUIScaleSize,
						v:GetAttribute("StandardSize").Y.Offset * GlobalUIScaleSize
					)
					print(v:GetAttribute("StandardSize"))
					print(v.Name, ": ", v.Size)
				end
				if v:IsA("TextButton") and v.Name ~= "Title" then
					--- continue
				end
			end
		end


		---- Main UI ----
		local MainUI = UI.MainScroll
		MainUI.Buttons.ImportUI.MouseButton1Click:Connect(function() -- Import UI
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			MainUI.Visible = false
			ImportUI.Visible = true
		end)

		MainUI.Buttons.AnchorUI.MouseButton1Click:Connect(function() -- Position UI
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			MainUI.Visible = false
			AnchorUI.Visible = true
		end)

		--[[MainUI.Buttons.ZIndexManager.MouseButton1Click:Connect(function() -- Manage Zindex
			MainUI.Visible = false
			ZIndexUI.Visible = true
		end)]]--

		UI.Title.MouseButton1Click:Connect(function() -- Main Menu
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			MainScroll.Visible = true
			for i, v in ipairs(UI:GetChildren()) do
				if v:IsA("ScrollingFrame") and v.Name ~= "MainScroll" then
					v.Visible = false
				end
			end
		end)

		MainUI.QuickActions.Title.MouseButton1Click:Connect(function() -- Extend and Shrink Quick Actions
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local CurrentSection = MainUI.QuickActions
			local Title = CurrentSection.Title

			for i, v in ipairs(CurrentSection.Frame.Buttons:GetChildren()) do
				if v:IsA("TextButton") or v:IsA("ImageButton") then
					v.Visible = not v.Visible
				end
			end
			Title.ArrowIcon.Rotation += 90
			if Title.ArrowIcon.Rotation == 180 then
				Title.ArrowIcon.Rotation = 0
			end
		end)

		MainUI.QuickPosition.Title.MouseButton1Click:Connect(function() -- Extend and Shrink Quick Positions
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local CurrentSection = MainUI.QuickPosition
			local Title = CurrentSection.Title

			for i, v in ipairs(CurrentSection.Buttons.ContainPresetButtons.Buttons:GetChildren()) do
				if v:IsA("TextButton") or v:IsA("ImageButton") then
					v.Visible = not v.Visible
				end
			end
			Title.ArrowIcon.Rotation += 90
			if Title.ArrowIcon.Rotation == 180 then
				Title.ArrowIcon.Rotation = 0
			end
		end)

		MainUI.QuickText.Title.MouseButton1Click:Connect(function() -- Extend and Shrink Quick Text
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local CurrentSection = MainUI.QuickText
			local Title = CurrentSection.Title

			for i, v in ipairs(CurrentSection.Frame.Buttons:GetChildren()) do
				if v:IsA("TextButton") or v:IsA("ImageButton") then
					v.Visible = not v.Visible
				end
			end
			Title.ArrowIcon.Rotation += 90
			if Title.ArrowIcon.Rotation == 180 then
				Title.ArrowIcon.Rotation = 0
			end
		end)

		MainUI.EditPreferences.Title.MouseButton1Click:Connect(function() -- Extend and Shrink Quick Text
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local CurrentSection = MainUI.EditPreferences
			local Title = CurrentSection.Title

			for i, v in ipairs(CurrentSection:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = not v.Visible
				end
			end
			Title.ArrowIcon.Rotation += 90
			if Title.ArrowIcon.Rotation == 180 then
				Title.ArrowIcon.Rotation = 0
			end
		end)


		--Quick Actions
		local QuickActions = MainUI.QuickActions
		-- Fast Scale
		local FastScale = QuickActions.Frame:WaitForChild("Buttons").ScaleUI

		FastScale.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording(FastScale.Name,tostring(recordingNum))
			if not recording then
				return warn("Could not record a new action, try to restart Studio or contact the developer.")
			end
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("ImageLabel") or v:IsA("ImageButton") or v:IsA("ViewportFrame") or v:IsA("VideoFrame") or v:IsA("ScrollingFrame")then
					local ParentSize = nil
					if v.Parent:IsA("ScreenGui") then
						ParentSize = game.Workspace.Camera.ViewportSize
					elseif v.Parent:IsA("GuiObject") then
						ParentSize = v.Parent.AbsoluteSize
					else
						local loop = true
						local w = v.Parent
						while loop == true do
							if w.Parent:IsA("GuiObject") then
								ParentSize = w.Parent.AbsoluteSize
								loop = false
							else
								w = w.Parent
							end
						end
					end

					if v.Size.X.Offset ~= 0 then
						v.Size = UDim2.new((v.Size.X.Offset / ParentSize.X) + v.Size.X.Scale, 0, v.Size.Y.Scale, v.Size.Y.Offset)
					end
					if v.Size.Y.Offset ~= 0 then
						v.Size = UDim2.new(v.Size.X.Scale, v.Size.X.Offset, (v.Size.Y.Offset / ParentSize.Y) + v.Size.Y.Scale, 0)
					end

					if v.Position.X.Offset ~= 0 then
						v.Position = UDim2.new((v.Position.X.Offset / ParentSize.X) + v.Position.X.Scale, 0, v.Position.Y.Scale, v.Position.Y.Offset)
					end
					if v.Position.Y.Offset ~= 0 then
						v.Position = UDim2.new(v.Position.X.Scale, v.Position.X.Offset, (v.Position.Y.Offset / ParentSize.Y) + v.Position.Y.Scale, 0)
					end
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- Fit Parent
		local FitParent = QuickActions.Frame.Buttons.FitParent

		FitParent.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording(FitParent.Name,tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("GuiObject") then
					v.Size = UDim2.new(1, 0, 1, 0)
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--Transparent
		local TransparentBtn = QuickActions.Frame.Buttons.TransparentBack

		TransparentBtn.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("Transparent",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do 
				if v:IsA("GuiObject") then
					v.BackgroundTransparency = 1
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--Ratio
		local Ratio = QuickActions.Frame.Buttons.AddConstraint

		Ratio.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("Ratio",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do 
				if v:IsA("GuiObject") then
					local ParentSize = nil
					if v.Parent:IsA("ScreenGui") then
						ParentSize = game.Workspace.Camera.ViewportSize
					elseif v.Parent:IsA("GuiObject") then
						ParentSize = v.Parent.AbsoluteSize
					else
						local loop = true
						local w = v.Parent
						while loop == true do
							if w.Parent:IsA("GuiObject") then
								ParentSize = w.Parent.AbsoluteSize
								loop = false
							else
								w = w.Parent
							end
						end
					end

					local Constraint = Instance.new("UIAspectRatioConstraint")
					Constraint.Parent = v
					Constraint.Name = "UIAspectRatioConstraint"
					Constraint.AspectRatio = (v.Size.X.Offset + (v.Size.X.Scale*ParentSize.X)) / (v.Size.Y.Offset + (v.Size.Y.Scale*ParentSize.Y))
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- Round Borders
		local RoundBorders = QuickActions.Frame.Buttons.RoundCorner
		RoundBorders.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("RoundBorders",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("GuiObject") then
					local Corner
					if not v:FindFirstChildOfClass("UICorner") then
						Corner = Instance.new("UICorner")
					else
						Corner = v:FindFirstChildOfClass("UICorner")
					end
					Corner.Parent = v
					Corner.Name = "UICorner"
					Corner.CornerRadius = UDim.new(GlobalBorderRadius, 0)
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--Square Shape
		local SquareShape = QuickActions.Frame.Buttons.SquareShape
		SquareShape.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("SquareShape",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("GuiObject") then
					if not v:FindFirstChildOfClass("UIAspectRatioConstraint") then
						local AspectRatio = Instance.new("UIAspectRatioConstraint")
						AspectRatio.AspectRatio = 1
						AspectRatio.Parent = v
						AspectRatio.Name = "UIAspectRatioConstraint"
					else
						v:FindFirstChildOfClass("UIAspectRatioConstraint").AspectRatio = 1
					end
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--Smart UIScale
		local SmartUIScale = QuickActions.Frame.Buttons.SmartUIScale
		SmartUIScale.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("SmartUIScale",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("GuiObject") then
					local ParentSize = nil
					if v.Parent:IsA("ScreenGui") then
						ParentSize = game.Workspace.Camera.ViewportSize
					elseif v.Parent:IsA("GuiObject") then
						ParentSize = v.Parent.AbsoluteSize
					else
						local loop = true
						local w = v.Parent
						while loop == true do
							if w.Parent:IsA("GuiObject") then
								ParentSize = w.Parent.AbsoluteSize
								loop = false
							else
								w = w.Parent
							end
						end
					end
					local PositionInOffset = UDim2.new(0, (ParentSize.X * v.Position.X.Scale) + v.Position.X.Offset, 0, (ParentSize.Y * v.Position.Y.Scale) + v.Position.Y.Offset)
					local SizeInOffset = v.AbsoluteSize
					local OffsetX = nil
					local OffsetY = nil
					if v.AnchorPoint.X == 1 then 
						OffsetX = PositionInOffset.X.Offset - SizeInOffset.X/2
					else
						OffsetX = PositionInOffset.X.Offset + (SizeInOffset.X - SizeInOffset.X / (2 - 2 * v.AnchorPoint.X))
					end
					if v.AnchorPoint.Y == 1 then 
						OffsetY = PositionInOffset.Y.Offset - SizeInOffset.Y/2
					else
						OffsetY = PositionInOffset.Y.Offset + (SizeInOffset.Y - SizeInOffset.Y / (2 - 2 * v.AnchorPoint.Y))
					end
					local NewPositionInOffset = UDim2.new(0, OffsetX, 0, OffsetY)	
					v.AnchorPoint = Vector2.new(0.5,0.5)
					v.Position = NewPositionInOffset
					if v.Position.X.Offset ~= 0 then
						v.Position = UDim2.new((v.Position.X.Offset / ParentSize.X) + v.Position.X.Scale, 0, v.Position.Y.Scale, v.Position.Y.Offset)
					end
					if v.Position.Y.Offset ~= 0 then
						v.Position = UDim2.new(v.Position.X.Scale, v.Position.X.Offset, (v.Position.Y.Offset / ParentSize.Y) + v.Position.Y.Scale, 0)
					end
					local UIScaleExists = false
					for i, w in ipairs(v:GetChildren()) do
						if w:IsA("UIScale") then
							UIScaleExists = true
							SmartUIScale.BackgroundColor3 = Color3.new(0.235294, 0.109804, 0.109804)
							warn("UIScale already exists")
							wait(0.5)
							SmartUIScale.BackgroundColor3 = Color3.new(0.235294, 0.235294, 0.235294)
						end
					end
					if not UIScaleExists then
						local UIScale = Instance.new("UIScale")
						UIScale.Parent = v
						print(GlobalUIScaleSize)
						UIScale.Scale = GlobalUIScaleSize
					end
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)

		end)

		--Sort Names
		local SortNames = QuickActions.Frame.Buttons.SortNames
		SortNames.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end
			
			local recording = CHS:TryBeginRecording("SortNames",tostring(recordingNum))
			recordingNum+=1
			local count = 1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("GuiObject") then
					v.Name = v.Name..tostring(count)
					count += 1
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--Quick Position
		local QuickPosition = MainUI.QuickPosition
		local QuickPositionPresets = QuickPosition.Buttons.ContainPresetButtons
		for i, v in ipairs(QuickPositionPresets.Buttons:GetChildren()) do			
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

					local recording = CHS:TryBeginRecording("QuickPosition",tostring(recordingNum))
					recordingNum+=1
					for _, w in pairs(Selection:Get()) do
						if w:IsA("GuiObject") then
							local splitAnchors = v.Text:split(",")
							w.AnchorPoint = Vector2.new(tonumber(splitAnchors[1]), tonumber(splitAnchors[2]))
							w.Position = UDim2.new(tonumber(splitAnchors[1]),0, tonumber(splitAnchors[2]),0)
						end
					end
					CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
				end)
			end
		end


		--Quick Text
		local QuickText = MainUI.QuickText

		-- Dark Theme
		local DarkTheme = QuickText.Frame.Buttons.DarkTheme
		DarkTheme.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end
			
			local recording = CHS:TryBeginRecording("DarkTheme"..tostring(recordingNum),"Easy UI Tools: Dark Theme applied")
			print("Recording: ",CHS:IsRecordingInProgress())
			print(recordingNum, ": ", recording)
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("TextButton") or v:IsA("TextLabel") then
					v.TextColor3 = Color3.fromRGB(255, 255, 255)
					if v.BackgroundColor3 == Color3.new(1, 1, 1) and v.Transparency == 0 then
						v.BackgroundColor3 = Color3.fromRGB(25, 25, 25)	
					end
					v.Font = GlobalFontFace
				end
			end
			print(recordingNum, ": ", recording)
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- Light Theme
		local LightTheme = QuickText.Frame.Buttons.LightTheme
		LightTheme.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end
			
			local recording = CHS:TryBeginRecording("LightTheme"..tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("TextButton") or v:IsA("TextLabel") then
					v.TextColor3 = Color3.fromRGB(0, 0, 0)
					if v.Transparency == 0 then
						v.BackgroundColor3 = Color3.fromRGB(255, 255, 255)	
					end
					v.Font = GlobalFontFace
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- Scaled Text
		local ScaledText = QuickText.Frame.Buttons.Scaled
		ScaledText.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end
			
			local recording = CHS:TryBeginRecording("ScaledText",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("TextButton") or v:IsA("TextLabel") then
					v.TextScaled = true
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- Stroke Text
		local StrokeText = QuickText.Frame.Buttons.AddStroke
		StrokeText.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end
			
			local recording = CHS:TryBeginRecording("StrokeText",tostring(recordingNum))
			recordingNum+=1
			for _, v in pairs(Selection:Get()) do
				if v:IsA("TextButton") or v:IsA("TextLabel") then
					local Stroke
					if not v:FindFirstChildOfClass("UIStroke") then
						Stroke = Instance.new("UIStroke")
					else
						Stroke = v:FindFirstChildOfClass("UIStroke")
					end

					Stroke.Thickness = GlobalStrokeThickness
					if v.BackgroundColor3 == Color3.new(1,1,1) then
						Stroke.Color = Color3.new(0,0,0)
						v.TextColor3 = Color3.new(1,1,1)
					else
						Stroke.Color = Color3.new(1, 1, 1)
						v.TextColor3 = Color3.new(0, 0, 0)
					end

					Stroke.Parent = v
					Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--open preferences
		local PreferenceFrameIn =   TweenService:Create(UI.NotListed.PreferencesFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, .8), {Position = UDim2.new(.5,0,1,0)})
		local PreferenceFrameOut =  TweenService:Create(UI.NotListed.PreferencesFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, .8), {Position = UDim2.new(.5,0,1.6,0)})
		local DarkBackgroundIn = 	TweenService:Create(UI.NotListed.DarkBackground, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = .5})
		local DarkBackgroundOut = 	TweenService:Create(UI.NotListed.DarkBackground, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
		local AnimPlaying = false

		UI.NotListed.PreferencesButtonFrame.Preferences.MouseButton1Click:Connect(function()
			if not AnimPlaying then
				UI.NotListed.DarkBackground.Size = UDim2.new(1,0,1,0)
				UI.NotListed.PreferencesHintLabel.Visible = false
				
				AnimPlaying = true
				UI.NotListed.PreferencesFrame.Visible = true
				UI.NotListed.DarkBackground.Visible = true
				PreferenceFrameOut:Cancel()
				PreferenceFrameIn:Play()
				DarkBackgroundOut:Cancel()
				DarkBackgroundIn:Play()
				wait(.5)
				AnimPlaying = false
			end
		end)
		UI.NotListed.PreferencesFrame.NotListed.DoneButton.MouseButton1Click:Connect(function()
			if not AnimPlaying then
				AnimPlaying = true
				PreferenceFrameIn:Cancel()
				PreferenceFrameOut:Play()
				DarkBackgroundIn:Cancel()
				DarkBackgroundOut:Play()
				wait(.5)
				UI.NotListed.PreferencesFrame.Visible = false
				UI.NotListed.DarkBackground.Visible = false
				AnimPlaying = false
			end
		end)
		--Edit Preferences
		local EditPreferences = UI.NotListed.PreferencesFrame
		local DropdownVisible = false
		--Plugin Scale
		local PluginScaleFrame = EditPreferences.PluginScale
		PluginScaleFrame.Selection.PlaceholderText = "1"
		if plugin:GetSetting(PluginScaleKey) ~= nil then
			PluginScaleFrame.Selection.PlaceholderText = plugin:GetSetting(PluginScaleKey)
		end
		local PluginScaleKey = PluginScaleKey
		PluginScaleFrame.Selection.FocusLost:Connect(function()
			local inputValue = tonumber(PluginScaleFrame.Selection.Text)
			if inputValue then
				inputValue = math.clamp(inputValue, 0.8, 1.2)
				plugin:SetSetting(PluginScaleKey, tostring(inputValue))
				PluginScaleFrame.Selection.PlaceholderText = tostring(inputValue)
				PluginScaleFrame.Selection.Text = ""
				GlobalPluginScale = inputValue
				ScalePlugin()
			elseif PluginScaleFrame.Selection.Text ~= "" then
				warn("Invalid Input: ", PluginScaleFrame.Selection.Text)
				PluginScaleFrame.Selection.Text = ""
			end
		end)

		--AccentColor
		local ColorsSelection = EditPreferences.Colors

		local function setAccentColor(btn)
			if DropdownVisible then
				return
			end
			if btn then 
				plugin:SetSetting(AccentColorKey, tostring(btn.BackgroundColor3:ToHex()))
				GlobalAccentColor = btn.BackgroundColor3:ToHex()
				btn.UIStroke.Enabled = true				
			end

			for i, v in ipairs(ColorsSelection:GetChildren()) do
				if v:IsA("TextButton") then
					if not btn and v.BackgroundColor3:ToHex() == plugin:GetSetting(AccentColorKey) then
						plugin:SetSetting(AccentColorKey, tostring(v.BackgroundColor3:ToHex()))
						GlobalAccentColor = v.BackgroundColor3:ToHex()
						v.UIStroke.Enabled = true
					end
					if v.BackgroundColor3:ToHex() ~= plugin:GetSetting(AccentColorKey) then
						v.UIStroke.Enabled = false
					end
				end
			end

			for i, v in ipairs(MainUI:GetDescendants())do
				if v:IsA("TextButton") and v.Name =="Title" then
					v.BackgroundColor3 = Color3.fromHex(GlobalAccentColor)
				end
			end
		end


		for i,v in ipairs(ColorsSelection:GetChildren()) do
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					setAccentColor(v)
				end)
			end
		end
		setAccentColor()

		--FontFace
		local availableFonts = Enum.Font:GetEnumItems()
		local validFonts = {}
		local FontClicked = false
		local function createFontDropdown(UI)
			local dropdown = UI.NotListed.PreferencesFrame.FontFace.DropdownMenu
			dropdown.Visible = true
			local dropdownItems = {}
			local elementFolder = Instance.new("Folder")
			elementFolder.Name = "FontsDropdown"
			elementFolder.Parent = dropdown
			local GridLayout = dropdown.UIGridLayout:Clone()
			GridLayout.Parent = elementFolder

			for _, fontEnum in ipairs(availableFonts) do
				if fontEnum.Name == "Unknown" then
					continue
				end
				local fontItem = dropdown.TemplateFont:Clone()
				fontItem.Text = fontEnum.Name
				fontItem.Name = fontEnum.Name
				fontItem.Font = fontEnum
				fontItem.Parent = elementFolder
				fontItem.Visible = true
				fontItem.MouseButton1Down:Connect(function()
					FontClicked = true
					local selectedFont = fontEnum.Name
					dropdown.Visible = false	
					elementFolder:Destroy()
					dropdown.Parent.Selection.Text = tostring(selectedFont)
					print(selectedFont, " ", typeof(selectedFont)," ",type(selectedFont))
					plugin:SetSetting(FontFaceKey, tostring(selectedFont))
					return
				end)
				table.insert(dropdownItems, fontItem)
			end
			return dropdown
		end
		for _, fontEnum in ipairs(availableFonts) do
			if fontEnum.Name ~= "Unknown" then
				validFonts[fontEnum.Name] = true
			end
		end
		local function isValidFont(fontName)
			return validFonts[fontName] ~= nil
		end
		
		local DropdownFontThread
		local FontFace = EditPreferences.FontFace
		FontFace.Selection.PlaceholderText = "SourceSans"
		if plugin:GetSetting(FontFaceKey) ~= nil then
			FontFace.Selection.PlaceholderText = plugin:GetSetting(FontFaceKey)
		end
			FontFace.Selection.Focused:Connect(function()
			DropdownVisible = true
			FontClicked = false
			DropdownFontThread = task.spawn(function()
				createFontDropdown(UI)
			end)		
		end)

		local function DropdownFocusLost()
			local failsafe = 0
			while not FontClicked do
				if failsafe <= 2 then
					task.wait(0.01)
					failsafe+=1
				else
					task.cancel(DropdownFontThread)
					break
				end
			end
			if isValidFont(FontFace.Selection.Text) then
				print(plugin:GetSetting(FontFaceKey))
				FontFace.Selection.PlaceholderText = tostring(FontFace.Selection.Text)
				FontFace.Selection.Text = ""
				GlobalFontFace = tostring(plugin:GetSetting(FontFaceKey))	
				UI.NotListed.PreferencesFrame.FontFace.DropdownMenu.Visible = false
				if UI.NotListed.PreferencesFrame.FontFace.DropdownMenu:FindFirstChild("FontsDropdown") then
					UI.NotListed.PreferencesFrame.FontFace.DropdownMenu.FontsDropdown:Destroy()
				end
			else
				warn("Invalid Input: ", FontFace.Selection.Text)
				FontFace.Selection.PlaceholderText = tostring(plugin:GetSetting(FontFaceKey))
				UI.NotListed.PreferencesFrame.FontFace.DropdownMenu.Visible = false
				UI.NotListed.PreferencesFrame.FontFace.DropdownMenu.FontsDropdown:Destroy()
				FontFace.Selection.Text = ""
			end
			DropdownVisible = false
		end
		
		FontFace.Selection.FocusLost:Connect(function()
			DropdownFocusLost()
		end)
		
		--Stroke Thickness
		local StrokeThickness = EditPreferences.StrokeThickness
		StrokeThickness.Selection.PlaceholderText = "3"
		if plugin:GetSetting(StrokeThicknessKey) ~= nil then
			StrokeThickness.Selection.PlaceholderText = plugin:GetSetting(StrokeThicknessKey)
		end
		local StrokeThicknessKey = StrokeThicknessKey
		StrokeThickness.Selection.FocusLost:Connect(function()
			local inputValue = tonumber(StrokeThickness.Selection.Text)
			if inputValue then
				plugin:SetSetting(StrokeThicknessKey, tostring(StrokeThickness.Selection.Text))
				StrokeThickness.Selection.PlaceholderText = tostring(StrokeThickness.Selection.Text)
				StrokeThickness.Selection.Text = ""
				GlobalStrokeThickness = tonumber(plugin:GetSetting(StrokeThicknessKey))
			elseif StrokeThickness.Selection.Text ~= "" then
				warn("Invalid Input: ", StrokeThickness.Selection.Text)
				StrokeThickness.Selection.Text = ""
			end
		end)

		--Border Radius
		local BorderRadius = EditPreferences.BorderRadius
		BorderRadius.Selection.PlaceholderText = "0.2"
		if plugin:GetSetting(BorderRadiusKey) ~= nil then
			BorderRadius.Selection.PlaceholderText = plugin:GetSetting(BorderRadiusKey)
		end
		local BorderRadiusKey = BorderRadiusKey
		BorderRadius.Selection.FocusLost:Connect(function()
			local inputValue = tonumber(BorderRadius.Selection.Text)
			if inputValue then
				plugin:SetSetting(BorderRadiusKey, tostring(BorderRadius.Selection.Text))
				BorderRadius.Selection.PlaceholderText = tostring(BorderRadius.Selection.Text)
				BorderRadius.Selection.Text = ""
				GlobalBorderRadius = tonumber(plugin:GetSetting(BorderRadiusKey))
			elseif BorderRadius.Selection.Text ~= "" then
				warn("Invalid Input: ", BorderRadius.Selection.Text)
				BorderRadius.Selection.Text = ""
			end
		end)

		--ShowToolTips
		local ShowTooltips = EditPreferences.ShowToolTip
		if plugin:GetSetting(ToolTipShowKey) ~= nil then
			ShowTooltips.Selection.Text = tostring(plugin:GetSetting(ToolTipShowKey))
		end
		local ShowTooltipsKey = ToolTipShowKey
		ShowTooltips.Selection.MouseButton1Click:Connect(function()
			if plugin:GetSetting(ShowTooltipsKey) == false then
				plugin:SetSetting(ShowTooltipsKey, true)
				ShowTooltips.Selection.Text = "true"
				GlobalToolTipShow = true
			else
				plugin:SetSetting(ShowTooltipsKey, false)
				ShowTooltips.Selection.Text = "false"
				GlobalToolTipShow = false
			end
		end)

		--UIScaleSize
		local UIScaleSize = EditPreferences.UIScaleSize
		UIScaleSize.Selection.PlaceholderText = GlobalUIScaleSize
		if plugin:GetSetting(UIScaleSizeKey) ~= nil then
			UIScaleSize.Selection.PlaceholderText = tostring(plugin:GetSetting(UIScaleSizeKey))
		end
		UIScaleSize.Selection.FocusLost:Connect(function()
			local inputValue = tonumber(UIScaleSize.Selection.Text)
			if inputValue then
				plugin:SetSetting(UIScaleSizeKey, tostring(UIScaleSize.Selection.Text))
				UIScaleSize.Selection.PlaceholderText = tostring(UIScaleSize.Selection.Text)
				GlobalUIScaleSize = tonumber(plugin:GetSetting(UIScaleSizeKey))
				UIScaleSize.Selection.Text = ""
			elseif UIScaleSize.Selection.Text ~= "" then
				warn("Invalid Input: ", UIScaleSize.Selection.Text)
				UIScaleSize.Selection.Text = ""
			end
		end)


		---- Import UI Layout ----
		local ImportUILayout = ImportUI.ImportUILayout
		ImportUILayout.Buttons.Simple.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("ImportSimpleLayout")
			local SimpleLayout = script.SimpleLayout:Clone()
			SimpleLayout.Parent = game.StarterGui
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		ImportUILayout.Buttons.Extended.MouseButton1Click:Connect(function()
			if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

			local recording = CHS:TryBeginRecording("ImportExtendedLayout")
			local ExtendedLayout = script.ExtendedLayout:Clone()
			ExtendedLayout.Parent = game.StarterGui
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		--UI Elements
		local Elements_Buttons = ImportUI.ImportUIElements.Buttons
		for i, v in ipairs(Elements_Buttons:GetChildren()) do
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

					local recording = CHS:TryBeginRecording("ImportUIElement")
					for _, w in pairs(Selection:Get()) do
						local newV = Instance.new(tostring(v.Text))
						newV.Size = UDim2.new(0.1,0,0.05,0)
						newV.BackgroundColor3 = Color3.fromHex("#fff")
						newV.Parent = w
						newV.BorderSizePixel = 0
					end
					CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
				end)
			end
		end

		--Anchor UI

		local AnchorUIPresets = AnchorUI.AnchorUIPresets.Buttons.ContainPresetButtons
		for i, v in ipairs(AnchorUIPresets.Buttons:GetChildren()) do
			if v:IsA("TextButton") then
				v.MouseButton1Click:Connect(function()
					if UI.NotListed.PreferencesFrame.Visible == true or UI.NotListed.DarkBackground.Visible == true then return end

					local recording = CHS:TryBeginRecording("AnchorUI")
					for _, w in pairs(Selection:Get()) do
						if w:IsA("GuiObject") then
							local splitAnchors = v.Text:split(",")
							w.AnchorPoint = Vector2.new(tonumber(splitAnchors[1]), tonumber(splitAnchors[2]))
							w.Position = UDim2.new(tonumber(splitAnchors[1]),0, tonumber(splitAnchors[2]),0)
						end
					end
					CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
				end)
			end
		end

		AnchorUI.CustomAnchor.TextBox.FocusLost:Connect(function()
			local recording = CHS:TryBeginRecording("CustomAnchor")
			for _, w in pairs(Selection:Get()) do
				if w:IsA("GuiObject") then
					local splitAnchors = AnchorUI.CustomAnchor.TextBox.Text:split(",")
					w.AnchorPoint = Vector2.new(tonumber(splitAnchors[1]), tonumber(splitAnchors[2]))
				end
			end
			CHS:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
		end)

		-- ZIndex Manager
		--[[
		local ZIndexParentLabel = ZIndexUI.CurrentParent
		local Template = ZIndexUI.Overview.Storage.Template
		local function reloadScreen(w)
			for i, v in ipairs(ZIndexUI.Overview:GetChildren()) do
				if v:IsA("TextButton") then
					v:Destroy()
				end
			end
			for i, v in ipairs(w.Parent:GetChildren()) do
				if v:IsA("GuiObject") then
					local Label = Template:Clone()
					Label.LayerName.Text = v.Name
					Label.ZIndexLabel.Text = v.ZIndex
					Label.LinkedObject.Value = v
					Label.Visible = true
					Label.Parent = Template.Parent.Parent
					Label.Name = v.Name
					Label.LayoutOrder = v.ZIndex*-1
					print(".")
				end
			end
		end
		Selection.SelectionChanged:Connect(function()
			if ZIndexUI.Visible == true then
				local SelectCount = 0
				for _, w in pairs(Selection:Get()) do
					if w:IsA("GuiObject") then
						SelectCount += 1	
						if SelectCount == 1 then
							ZIndexParentLabel.Text = "Current Parent: "..w.Parent.Name
							reloadScreen(w)
							for i, v in ipairs(ZIndexUI.Overview:GetChildren()) do
								if v:IsA("TextButton") then
									local MouseDown = false
									v.MouseButton1Down:Connect(function()
										MouseDown = true
										local dragObject = v
										while MouseDown do
											local mouseWidgetPosition = widget:GetRelativeMousePosition();
											local maxPosition = v.AbsolutePosition.Y + v.AbsoluteSize.Y
											local minPosition = v.AbsolutePosition.Y
											local MouseOffset = mouseWidgetPosition.Y - v.AbsolutePosition.Y
											local countAbove = 0
											local countBelow = 0
											local realAbove  = 0
											local realBelow  = 0

											for i, v in ipairs(w.Parent:GetChildren()) do
												if v:IsA("TextButton") then
													if v ~= dragObject then
														if v.LayoutOrder < dragObject.LayoutOrder then
															countAbove += 1
														elseif v.LayoutOrder > dragObject.LayoutOrder then
															countBelow += 1
														end
														if v.AbsolutePosition.Y + v.AbsoluteSize.Y < dragObject.AbsolutePosition.Y then
															realAbove += 1
														elseif v.AbsolutePosition.Y > dragObject.AbsolutePosition.Y then
															realBelow += 1
														end
													end
												end
											end

											print("Mouse: ", mouseWidgetPosition, "MaxPos: ", maxPosition, "MinPos", minPosition, "AbsPos: ", v.AbsolutePosition.Y)
											print("Above:", countAbove, "Below:", countBelow, "realAbove: ", realAbove, "realBelow: ", realBelow)
											if mouseWidgetPosition.Y > maxPosition + 5 then
												local ZindexDifference = -1
												for i, v in ipairs(ZIndexUI.Overview:GetChildren()) do
													if v:IsA("TextButton") then
														if v.LayoutOrder >= w.LayoutOrder+ZindexDifference then
															v.ZIndex += 1
														end
													end
												end
												w.ZIndex -= 1
												warn("-")
												reloadScreen(w)
											end
											if mouseWidgetPosition.Y < minPosition - 5 then
												local ZindexDifference = 1
												for i, v in ipairs(ZIndexUI.Overview:GetChildren()) do
													if v:IsA("TextButton") then
														if v.LayoutOrder >= w.LayoutOrder+ZindexDifference then
															v.ZIndex += 1
														end
													end
												end
												w.ZIndex += 1
												warn("+")
												reloadScreen(w)
											end

											if mouseWidgetPosition.Y > maxPosition + 55 or
												mouseWidgetPosition.Y < minPosition - 50 or
												mouseWidgetPosition.X > v.AbsolutePosition.X + v.AbsoluteSize.X + 10 or
												mouseWidgetPosition.X < v.AbsolutePosition.X - 10 then
												MouseDown = false
												warn("Mouse out of bounds, moving ended")
											end

											wait(0.1)

										end
									end)
									v.MouseButton1Up:Connect(function()
										MouseDown = false
									end)

								end
							end
						end
					end
				end
			end
		end)]]
	end
end


--Functions
local function InitializePluginUI()
	if not GlobalWidget then
		ImportBasicLayoutButtonClicked()
		GlobalWidget = widget
		GlobalWidget.Enabled = true
		Enabled = true
	end
end

InitializePluginUI()


toolbarButton.Click:Connect(function()
	if not Enabled then
		GlobalWidget.Enabled = true
		Enabled = true
	else
		GlobalWidget.Enabled = false
		GlobalWidget.Main.MainScroll.Visible = true
		for i, v in ipairs(GlobalWidget.Main:GetChildren()) do
			if v:IsA("ScrollingFrame") and v.Name ~= "MainScroll" then
				v.Visible = false
			end
		end
		Enabled = false
	end
end)

plugin.Unloading:Connect(function()
	toolbar:Destroy()
	toolbarButton:Destroy()
end)

local function onEnabledChanged()
	toolbarButton:SetActive(GlobalWidget.Enabled)
	Enabled= GlobalWidget.Enabled
end 
widget:GetPropertyChangedSignal("Enabled"):Connect(onEnabledChanged)

