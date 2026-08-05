// Copyright (c) Files Community. Licensed under the MIT License.

namespace Files.App.Views.Shells
{
	/// <summary>
	/// Stable, visual-tree-independent access to the navigation state owned by a Files tab.
	/// Explorer shells consume this contract instead of reimplementing tab navigation.
	/// </summary>
	public interface IExplorerTabChrome
	{
		NavigationToolbarViewModel ToolbarViewModel { get; }
	}
}
