function fish_prompt
	if test (id -u) -eq 0
		set_color red --bold
	else
		set_color green --bold
	end

	echo -n '〉'
end
