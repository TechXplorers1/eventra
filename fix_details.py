import os

filepath = r'd:\company-work\eventra\lib\features\organizer\presentation\pages\organizer_event_detail_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix ServiceProviderProfile getters
content = content.replace("provider.id,", "provider.vendorId,")
content = content.replace("provider.experience", "provider.experienceYears")
content = content.replace("provider.jobsCompleted", "provider.totalGigs")

# Fix ServiceRequest creation
old_req = """                    final req = ServiceRequest(
                      id: 'SR${DateTime.now().millisecondsSinceEpoch}',
                      eventId: widget.eventId,
                      organizerId: 'O001',
                      vendorId: provider.id,
                      categoryName: provider.serviceCategory,
                      vendorName: provider.businessName,
                      vendorPrice: provider.startingPrice,
                      status: 'Quote Requested',
                      requestDate: DateTime.now().toIso8601String(),
                    );"""

new_req = """                    final req = ServiceRequest(
                      id: 'SR${DateTime.now().millisecondsSinceEpoch}',
                      eventId: widget.eventId,
                      eventName: widget.eventId, // Mock data
                      eventDate: '',
                      eventVenue: '',
                      categoryId: provider.serviceCategory, // Mock ID
                      vendorId: provider.vendorId,
                      categoryName: provider.serviceCategory,
                      vendorName: provider.businessName,
                      vendorPrice: provider.startingPrice.toDouble(),
                      status: 'Quote Requested',
                      budget: provider.startingPrice.toDouble(),
                      professionals: 1,
                      duration: '1 Day',
                      notes: '',
                      quotes: 1,
                      createdAt: DateTime.now(),
                    );"""

content = content.replace(old_req, new_req)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed dart file!')
