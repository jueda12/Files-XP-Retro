// Copyright (c) Files Community. Licensed under the MIT License.

namespace Files.App.Views.Shells
{
	public sealed partial class XpExplorerShell : UserControl
	{
		public UIElement? TitleTabContent
		{
			get => (UIElement?)GetValue(TitleTabContentProperty);
			set => SetValue(TitleTabContentProperty, value);
		}

		public static readonly DependencyProperty TitleTabContentProperty =
			DependencyProperty.Register(nameof(TitleTabContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));

		public UIElement? MenuContent
		{
			get => (UIElement?)GetValue(MenuContentProperty);
			set => SetValue(MenuContentProperty, value);
		}

		public static readonly DependencyProperty MenuContentProperty =
			DependencyProperty.Register(nameof(MenuContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));

		public UIElement? NavigationContent
		{
			get => (UIElement?)GetValue(NavigationContentProperty);
			set => SetValue(NavigationContentProperty, value);
		}

		public static readonly DependencyProperty NavigationContentProperty =
			DependencyProperty.Register(nameof(NavigationContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));

		public UIElement? NotificationContent
		{
			get => (UIElement?)GetValue(NotificationContentProperty);
			set => SetValue(NotificationContentProperty, value);
		}

		public static readonly DependencyProperty NotificationContentProperty =
			DependencyProperty.Register(nameof(NotificationContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));

		public UIElement? WorkspaceContent
		{
			get => (UIElement?)GetValue(WorkspaceContentProperty);
			set => SetValue(WorkspaceContentProperty, value);
		}

		public static readonly DependencyProperty WorkspaceContentProperty =
			DependencyProperty.Register(nameof(WorkspaceContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));

		public UIElement? StatusContent
		{
			get => (UIElement?)GetValue(StatusContentProperty);
			set => SetValue(StatusContentProperty, value);
		}

		public static readonly DependencyProperty StatusContentProperty =
			DependencyProperty.Register(nameof(StatusContent), typeof(UIElement), typeof(XpExplorerShell), new PropertyMetadata(null));
	}
}
