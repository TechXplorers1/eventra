import os
import re

router_path = r'd:\company-work\eventra\lib\core\router\app_router.dart'
with open(router_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
import_str = "import '../../features/service_provider/presentation/pages/service_provider_seating_manager_screen.dart';"
if import_str not in content:
    # find the last import from service_provider
    pattern = re.compile(r"import '../../features/service_provider/.*?';")
    matches = list(pattern.finditer(content))
    if matches:
        last_match = matches[-1]
        content = content[:last_match.end()] + '\n' + import_str + content[last_match.end():]

# Add route
route_str = "      GoRoute(path: '/service-provider/seating',    builder: (_, __) => const ServiceProviderSeatingManagerScreen()),"
if '/service-provider/seating' not in content:
    old_routes = "      GoRoute(path: '/service-provider/reviews',    builder: (_, __) => const ServiceProviderReviewsScreen()),"
    new_routes = "      GoRoute(path: '/service-provider/reviews',    builder: (_, __) => const ServiceProviderReviewsScreen()),\n" + route_str
    content = content.replace(old_routes, new_routes)

with open(router_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Added routing for seating manager.")
