from django.forms import fields
from widgets import GoogleMapsAddressWidget, GoogleMapsGeolocationWidget

class GeoLocationFormField(fields.CharField):
	def __init__(self, *args, **kwargs):
		defaults = {
			'widget':GoogleMapsGeolocationWidget(attrs={'class':'tag_field'})
		}
		defaults.update(kwargs)
		super(GeoLocationFormField, self).__init__(**defaults)
		print(self.widget)
