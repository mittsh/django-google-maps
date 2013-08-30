
from django.conf import settings
from django.forms import widgets
from django.utils.encoding import force_unicode
from django.utils.safestring import mark_safe
from django.forms.util import flatatt

class GoogleMapsAddressWidget(widgets.TextInput):
	'''
	A widget that will place a Google Map right after the #id_address field.
	'''
	
	class Media:
		css = {'all': (settings.STATIC_URL + 'django_google_maps/css/google-maps-admin.css',),}
		js = (
			'https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js',
			'http://maps.google.com/maps/api/js?sensor=false',
			settings.STATIC_URL + 'django_google_maps/js/google-maps-admin.js',
		)

	def render(self, name, value, attrs=None):
		if value is None:
			value = ''
		final_attrs = self.build_attrs(attrs, type=self.input_type, name=name)
		if value != '':
			# Only add the 'value' attribute if a value is non-empty.
			final_attrs['value'] = force_unicode(self._format_value(value))
		return mark_safe(u'<input%s /><div class="map_canvas_wrapper"><div id="map_canvas"></div></div>' % flatatt(final_attrs))

class GoogleMapsGeolocationWidget(widgets.TextInput):
	'''
	A widget that will place a Google Map right after the #id_address field.
	'''
	
	class Media:
		css = {'all': (settings.STATIC_URL + 'django_google_maps/css/django-google-maps.less.min.css',),}
		js = (
			'https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js',
			'https://maps.googleapis.com/maps/api/js?sensor=false' + ('&key=' + settings.GOOGLE_MAPS_API_KEY if hasattr(settings, 'GOOGLE_MAPS_API_KEY') else ''),
			settings.STATIC_URL + 'django_google_maps/src/site.js',
		)

	def render(self, name, value, attrs=None):
		
		if value is None:
			value = ''
		final_attrs = self.build_attrs(attrs, type=self.input_type, name=name)
		if value != '':
			# Only add the 'value' attribute if a value is non-empty.
			final_attrs['value'] = force_unicode(self._format_value(value))
		final_attrs['class'] = 'map_value'
		
		kwargs = {
			'final_attrs': flatatt(final_attrs),
			'field_id': final_attrs['id'],
			'enable_click_to_pick': 'false',
			'address_field_id': final_attrs['id'] + '_address',
		}
		
		kwargs['address_field'] = '<div class="map_value_address"><label>Address</label><input id="{address_field_id}" type="text" /></div>'.format(**kwargs)
		
		return mark_safe(u'<input{final_attrs} />{address_field}<div class="map_canvas_wrapper"><div id="map_canvas" class="map_canvas" data-field-id="{field_id}" data-enable-click-to-pick="{enable_click_to_pick}" data-address-field-id="{address_field_id}"></div></div>'.format(**kwargs))

















