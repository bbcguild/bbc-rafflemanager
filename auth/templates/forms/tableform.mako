%if form.errors.has_key('whole_form'):
	%for error in form.errors.get('whole_form'):
		<p class="field_error">${error}</p>
	%endfor
%endif

<form id="${form.__class__.__name__}" action="${action}" method="POST" accept-charset="utf-8"
	%if form.is_multipart:
		 enctype="multipart/form-data"
	%endif
	>
	<table class="login_table">
		%for lo, field in enumerate(form):
			<tr class="${['odd', 'even'][lo % 2]} login_row">
				<td class="${field.name}_col"><span id="${field.name}_field">${field.label}:</span>
				</td>
				<td class="${field.name}_col">${field}
					%if field.description:
						<span class="help_text">${field.description}</span>
					%endif
					%for error in field.errors:
						<span class="field_error">${error}</span>
					%endfor
				</td>
			</tr>
		%endfor
            <tr>
                <td colspan=2>
                    <span id="buttons_span">
                    <input id="submit" type="submit" name="submit" value="${submit_text}" />
                    <input id="clear" type="reset" value="Clear" />
                    </span>
                </td>
            </tr>
		${csrf_token_field|n}
	</table>
</form>
