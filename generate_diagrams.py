import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

out_dir = "/Users/joshua/.gemini/antigravity/scratch/campus_marketplace/assets/report_assets"
os.makedirs(out_dir, exist_ok=True)

plt.rcParams['font.sans-serif'] = 'Helvetica'
plt.rcParams['axes.edgecolor'] = '#1A365D'

# 1. System Architecture
fig, ax = plt.subplots(figsize=(8, 4.5), dpi=300)
ax.axis('off')

rect_ui = patches.FancyBboxPatch((0.5, 3.2), 7.0, 1.1, boxstyle="round,pad=0.1", ec="#1E3A8A", fc="#EFF6FF", lw=2)
rect_logic = patches.FancyBboxPatch((0.5, 1.8), 7.0, 1.1, boxstyle="round,pad=0.1", ec="#047857", fc="#ECFDF5", lw=2)
rect_data = patches.FancyBboxPatch((0.5, 0.4), 7.0, 1.1, boxstyle="round,pad=0.1", ec="#B45309", fc="#FFFBEB", lw=2)

ax.add_patch(rect_ui)
ax.add_patch(rect_logic)
ax.add_patch(rect_data)

ax.text(4.0, 3.9, "Presentation Layer (Flutter 3.x / Material 3)", fontsize=11, fontweight='bold', ha='center', color="#1E3A8A")
ax.text(4.0, 3.4, "Responsive Layouts • Custom Themes • QR Pass UI • Marketplace Grid • Search & Filters", fontsize=9, ha='center', color="#1E40AF")

ax.text(4.0, 2.5, "Application / Business Logic Layer (Riverpod 2.5)", fontsize=11, fontweight='bold', ha='center', color="#047857")
ax.text(4.0, 2.0, "AuthNotifier • MarketplaceNotifier • TransactionNotifier • RatingNotifier", fontsize=9, ha='center', color="#065F46")

ax.text(4.0, 1.1, "Data & Backend Layer (Firebase & Local Storage)", fontsize=11, fontweight='bold', ha='center', color="#B45309")
ax.text(4.0, 0.6, "Firebase Authentication • Cloud Firestore NoSQL • Security Rules • SharedPreferences", fontsize=9, ha='center', color="#92400E")

ax.annotate("", xy=(4.0, 3.2), xytext=(4.0, 2.9), arrowprops=dict(arrowstyle="<->", lw=2, color="#1E3A8A"))
ax.annotate("", xy=(4.0, 1.8), xytext=(4.0, 1.5), arrowprops=dict(arrowstyle="<->", lw=2, color="#047857"))

plt.title("Figure 5.1: Three-Tier System Architecture Diagram", fontsize=12, fontweight='bold', pad=10, color="#0F172A")
plt.tight_layout()
plt.savefig(os.path.join(out_dir, "fig_5_1_sys_arch.png"), bbox_inches='tight')
plt.close()

# 2. Physical Architecture
fig, ax = plt.subplots(figsize=(8, 4.2), dpi=300)
ax.axis('off')

box_client = patches.FancyBboxPatch((0.5, 1.0), 2.2, 2.4, boxstyle="round,pad=0.1", ec="#2563EB", fc="#DBEAFE", lw=2)
box_net = patches.FancyBboxPatch((3.2, 1.6), 1.6, 1.2, boxstyle="round,pad=0.1", ec="#4B5563", fc="#F3F4F6", lw=2)
box_cloud = patches.FancyBboxPatch((5.3, 0.8), 2.2, 2.8, boxstyle="round,pad=0.1", ec="#DC2626", fc="#FEE2E2", lw=2)

ax.add_patch(box_client)
ax.add_patch(box_net)
ax.add_patch(box_cloud)

ax.text(1.6, 3.0, "Mobile Client", fontsize=11, fontweight='bold', ha='center', color="#1E40AF")
ax.text(1.6, 2.2, "Android / iOS / Web\nFlutter Engine\nLocal Cache & State", fontsize=9, ha='center', color="#1D4ED8")

ax.text(4.0, 2.4, "Network", fontsize=10, fontweight='bold', ha='center', color="#374151")
ax.text(4.0, 1.9, "HTTPS / TLS\nWebSockets", fontsize=8, ha='center', color="#4B5563")

ax.text(6.4, 3.2, "Firebase Cloud", fontsize=11, fontweight='bold', ha='center', color="#991B1B")
ax.text(6.4, 2.3, "Firebase Auth Server\nCloud Firestore DB\nSecurity Engine\nCloud Storage", fontsize=8.5, ha='center', color="#B91C1C")

ax.annotate("", xy=(3.2, 2.2), xytext=(2.7, 2.2), arrowprops=dict(arrowstyle="<->", lw=2, color="#2563EB"))
ax.annotate("", xy=(5.3, 2.2), xytext=(4.8, 2.2), arrowprops=dict(arrowstyle="<->", lw=2, color="#DC2626"))

plt.title("Figure 5.1.1: Physical Deployment Architecture", fontsize=12, fontweight='bold', pad=10, color="#0F172A")
plt.tight_layout()
plt.savefig(os.path.join(out_dir, "fig_5_1_1_physical_arch.png"), bbox_inches='tight')
plt.close()

# 3. Use Case Diagram
fig, ax = plt.subplots(figsize=(8, 4.8), dpi=300)
ax.axis('off')

ax.add_patch(patches.Circle((1.0, 3.2), 0.28, ec="#1E293B", fc="#E2E8F0", lw=2))
ax.plot([1.0, 1.0], [2.2, 2.92], color="#1E293B", lw=2)
ax.plot([0.5, 1.5], [2.6, 2.6], color="#1E293B", lw=2)
ax.plot([1.0, 0.6], [2.2, 1.4], color="#1E293B", lw=2)
ax.plot([1.0, 1.4], [2.2, 1.4], color="#1E293B", lw=2)
ax.text(1.0, 0.9, "Campus Student", fontsize=10, fontweight='bold', ha='center', color="#0F172A")

boundary = patches.Rectangle((2.8, 0.3), 4.8, 4.0, ec="#0284C7", fc="#F0F9FF", lw=2, linestyle='--')
ax.add_patch(boundary)
ax.text(5.2, 4.05, "Campus Marketplace System", fontsize=11, fontweight='bold', ha='center', color="#0369A1")

usecases = [
    ("UC1: Register & Login (Firebase Auth)", 3.4),
    ("UC2: Browse & Search Resource Listings", 2.8),
    ("UC3: Post New Item (Sell / Rent / Borrow)", 2.2),
    ("UC4: Initiate Buy/Borrow Transaction", 1.6),
    ("UC5: Generate & Scan QR Pickup Pass", 1.0),
    ("UC6: Rate & Review Peer User", 0.45)
]

for title, y in usecases:
    ellipse = patches.Ellipse((5.2, y+0.15), 3.8, 0.42, ec="#0284C7", fc="#FFFFFF", lw=1.5)
    ax.add_patch(ellipse)
    ax.text(5.2, y+0.15, title, fontsize=8.5, ha='center', va='center', color="#0C4A6E", fontweight='bold')
    ax.plot([1.5, 3.3], [2.4, y+0.15], color="#94A3B8", lw=1, linestyle=':')

plt.title("Figure 5.2: Use Case Diagram", fontsize=12, fontweight='bold', pad=10, color="#0F172A")
plt.tight_layout()
plt.savefig(os.path.join(out_dir, "fig_5_2_use_case.png"), bbox_inches='tight')
plt.close()

# 4. Flowchart
fig, ax = plt.subplots(figsize=(7, 5.0), dpi=300)
ax.axis('off')

nodes = [
    ("Start App", 4.4, "ellipse"),
    ("Authenticated?", 3.6, "rhombus"),
    ("Login / Register", 2.8, "box"),
    ("Explore Dashboard", 2.0, "box"),
    ("Select Item & Buy/Borrow", 1.2, "box"),
    ("QR Pass Verification", 0.4, "box")
]

for name, y, ntype in nodes:
    if ntype == "ellipse":
        patch = patches.FancyBboxPatch((2.2, y), 2.6, 0.45, boxstyle="circle,pad=0.2", ec="#16A34A", fc="#DCFCE7", lw=2)
    elif ntype == "rhombus":
        patch = patches.Polygon([[3.5, y+0.45], [4.8, y+0.2], [3.5, y-0.05], [2.2, y+0.2]], ec="#D97706", fc="#FEF3C7", lw=2)
    else:
        patch = patches.FancyBboxPatch((2.0, y), 3.0, 0.45, boxstyle="round,pad=0.1", ec="#2563EB", fc="#EFF6FF", lw=2)
    ax.add_patch(patch)
    ax.text(3.5, y+0.2, name, fontsize=9, fontweight='bold', ha='center', va='center', color="#0F172A")

ax.annotate("", xy=(3.5, 3.65), xytext=(3.5, 4.35), arrowprops=dict(arrowstyle="->", lw=1.5, color="#475569"))
ax.annotate("", xy=(3.5, 2.85), xytext=(3.5, 3.55), arrowprops=dict(arrowstyle="->", lw=1.5, color="#475569"))
ax.annotate("", xy=(3.5, 2.05), xytext=(3.5, 2.75), arrowprops=dict(arrowstyle="->", lw=1.5, color="#475569"))
ax.annotate("", xy=(3.5, 1.25), xytext=(3.5, 1.95), arrowprops=dict(arrowstyle="->", lw=1.5, color="#475569"))
ax.annotate("", xy=(3.5, 0.45), xytext=(3.5, 1.15), arrowprops=dict(arrowstyle="->", lw=1.5, color="#475569"))

plt.title("Figure 5.4: Application Flowchart", fontsize=12, fontweight='bold', pad=10, color="#0F172A")
plt.tight_layout()
plt.savefig(os.path.join(out_dir, "fig_5_4_flowchart.png"), bbox_inches='tight')
plt.close()

# 5. Entity Relationship Diagram
fig, ax = plt.subplots(figsize=(8, 4.0), dpi=300)
ax.axis('off')

users_box = patches.FancyBboxPatch((0.5, 1.2), 2.0, 2.2, boxstyle="round,pad=0.1", ec="#0284C7", fc="#F0F9FF", lw=2)
items_box = patches.FancyBboxPatch((3.0, 1.2), 2.0, 2.2, boxstyle="round,pad=0.1", ec="#16A34A", fc="#F0FDF4", lw=2)
trans_box = patches.FancyBboxPatch((5.5, 1.2), 2.0, 2.2, boxstyle="round,pad=0.1", ec="#D97706", fc="#FFFBEB", lw=2)

ax.add_patch(users_box)
ax.add_patch(items_box)
ax.add_patch(trans_box)

ax.text(1.5, 3.1, "USERS", fontsize=10, fontweight='bold', ha='center', color="#0369A1")
ax.text(1.5, 2.1, "• uid (PK)\n• name\n• email\n• phone\n• rating\n• campusBlock", fontsize=8, ha='left', color="#0C4A6E")

ax.text(4.0, 3.1, "ITEMS", fontsize=10, fontweight='bold', ha='center', color="#15803D")
ax.text(4.0, 2.1, "• id (PK)\n• title\n• price (INR)\n• type (Buy/Rent)\n• ownerId (FK)\n• status", fontsize=8, ha='left', color="#14532D")

ax.text(6.5, 3.1, "TRANSACTIONS", fontsize=10, fontweight='bold', ha='center', color="#B45309")
ax.text(6.5, 2.1, "• id (PK)\n• itemId (FK)\n• buyerId (FK)\n• qrCodeData\n• status\n• timestamp", fontsize=8, ha='left', color="#78350F")

ax.annotate("", xy=(3.0, 2.3), xytext=(2.5, 2.3), arrowprops=dict(arrowstyle="<->", lw=2, color="#475569"))
ax.text(2.75, 2.5, "1:N", fontsize=8, fontweight='bold', ha='center')
ax.annotate("", xy=(5.5, 2.3), xytext=(5.0, 2.3), arrowprops=dict(arrowstyle="<->", lw=2, color="#475569"))
ax.text(5.25, 2.5, "1:N", fontsize=8, fontweight='bold', ha='center')

plt.title("Figure 5.7: Cloud Firestore Entity Relationship (ER) Diagram", fontsize=12, fontweight='bold', pad=10, color="#0F172A")
plt.tight_layout()
plt.savefig(os.path.join(out_dir, "fig_5_7_er.png"), bbox_inches='tight')
plt.close()

print("All figures successfully created in assets/report_assets!")
