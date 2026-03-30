from wtforms import Form
from wtforms import HiddenField
from wtforms import PasswordField
from wtforms import StringField  # TextField was renamed to StringField
from wtforms import validators

from pyramid.i18n import TranslationString as _
from pyramid.security import remember
from pyramid.threadlocal import get_current_registry
from pyramid.threadlocal import get_current_request

from auth.models import AuthUser
from auth.lib.form import ExtendedForm

class LoginForm(ExtendedForm):
    username = StringField(_('Username'), validators=[validators.DataRequired()])
    password = PasswordField(_('Password'), validators=[validators.DataRequired()])
    
    def validate(self):
        """Custom validation that checks if basic field validation passes first"""
        # First run the standard field validators
        if not super().validate():
            return False
        
        # Only check authentication if basic validation passed
        # Let the view handle the actual authentication logic
        return True
