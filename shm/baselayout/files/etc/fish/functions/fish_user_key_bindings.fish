function fish_user_key_bindings
	bind -M insert \cr history-search-backward
	bind -M insert \cs history-search-forward
	bind -M insert \cf accept-autosuggestion
end
