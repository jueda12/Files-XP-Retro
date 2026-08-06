// Copyright (c) Files Community. Licensed under the MIT License.

using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace Files.App.Views.Shells
{
	/// <summary>
	/// The one layout owner for the XP Explorer window chrome. MainPage places
	/// existing Files controls directly into these rows; no control is re-parented
	/// through a visual-tree lookup or an overlay host.
	/// </summary>
	public sealed class XpExplorerShell : Grid
	{
		public XpExplorerShell()
		{
			RowDefinitions.Add(new RowDefinition { Height = new GridLength(44) }); // Title and tabs: fixed chrome contract, never invades menu
			RowDefinitions.Add(new RowDefinition { Height = new GridLength(26) }); // Classic menu
			RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Navigation and address
			RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Notifications
			RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Workspace
			RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Status
		}

		/// <summary>
		/// Navigation state owned by the active Files tab. The shell observes this
		/// contract and never creates a second history or path model.
		/// </summary>
		public IExplorerTabChrome? ActiveTabChrome
		{
			get => (IExplorerTabChrome?)GetValue(ActiveTabChromeProperty);
			set => SetValue(ActiveTabChromeProperty, value);
		}

		public static readonly DependencyProperty ActiveTabChromeProperty =
			DependencyProperty.Register(nameof(ActiveTabChrome), typeof(IExplorerTabChrome), typeof(XpExplorerShell), new PropertyMetadata(null));
	}
}
