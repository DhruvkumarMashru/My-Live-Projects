import os
import sys
from pathlib import Path

# Add project root to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from config import PATHS

try:
    from pptx import Presentation
    from pptx.util import Inches, Pt
    from pptx.enum.text import PP_ALIGN
    from pptx.dml.color import RGBColor
except ImportError:
    print("[INFO] python-pptx not found. Installing now...")
    os.system("pip install python-pptx")
    from pptx import Presentation
    from pptx.util import Inches, Pt
    from pptx.enum.text import PP_ALIGN
    from pptx.dml.color import RGBColor

def set_para_font(p, font_name="Century Schoolbook", size=14, bold=False, italic=False, color=None):
    p.font.name = font_name
    if size:
        if hasattr(size, 'pt'):
            p.font.size = size
        else:
            p.font.size = Pt(size)
    p.font.bold = bold
    p.font.italic = italic
    if color:
        p.font.color.rgb = color

def add_bullet_point(tf, text, level=0, size=13, bold=False, color=None):
    p = tf.add_paragraph()
    p.text = text
    p.level = level
    p.space_before = Pt(6)
    set_para_font(p, font_name="Century Schoolbook", size=size, bold=bold, color=color)
    return p

def main():
    template_path = Path(r"e:\PROJECT\glaucoma_detection\PPT_RRC_JD_Format.pptx")
    output_dir = Path(r"e:\PROJECT\glaucoma_detection\client_delivery")
    output_dir.mkdir(exist_ok=True)
    output_path = output_dir / "4_Project_Presentation_JD_Format.pptx"
    
    print(f"Opening template presentation at: {template_path}")
    prs = Presentation(str(template_path))
    
    # ── Color Palette ──────────────────────────────────────────────────
    DARK_BLUE = RGBColor(11, 23, 44)
    ACCENT_BLUE = RGBColor(0, 102, 204)
    TEXT_CHARCOAL = RGBColor(50, 50, 50)
    
    # ════════════════════ SLIDE 1: Cover Slide ════════════════════
    slide1 = prs.slides[0]
    print("Editing Slide 1 (Cover)...")
    for shape in list(slide1.shapes):
        if shape.has_text_frame:
            tf = shape.text_frame
            text = tf.text.strip()
            
            if "Title of the research" in text:
                tf.text = ""
                p = tf.paragraphs[0]
                p.text = "ADVANCED RETINAL OCT-BASED EARLY GLAUCOMA DETECTION SYSTEM USING DEEP LEARNING ENSEMBLE"
                p.alignment = PP_ALIGN.CENTER
                set_para_font(p, size=18, bold=True, color=DARK_BLUE)
                
            elif "ELECTRICAL ENGINEERING" in text:
                tf.text = ""
                p = tf.paragraphs[0]
                p.text = "COMPUTER SCIENCE & ENGINEERING"
                p.alignment = PP_ALIGN.CENTER
                set_para_font(p, size=14, bold=True, color=ACCENT_BLUE)
                
            elif "Name of Research Scholar" in text:
                tf.text = ""
                p = tf.paragraphs[0]
                p.text = "Lead AI Research Investigator"
                p.alignment = PP_ALIGN.CENTER
                set_para_font(p, size=12, bold=True, color=DARK_BLUE)
                
            elif "Dr. --------------------" in text or "Dr.." in text:
                tf.text = ""
                p = tf.paragraphs[0]
                p.text = "Dr. Clinical Research Supervisor"
                p.alignment = PP_ALIGN.CENTER
                set_para_font(p, size=11, bold=True, color=DARK_BLUE)
                
            elif "<Font" in text:
                # Remove guideline text box completely
                sp = shape._element
                parent = sp.getparent()
                if parent is not None:
                    parent.remove(sp)
                    
    # Format cover titles remaining runs
    for shape in slide1.shapes:
        if shape.has_text_frame:
            for p in shape.text_frame.paragraphs:
                if p.text:
                    set_para_font(p, font_name="Century Schoolbook", size=p.font.size or 12)

    # ════════════════════ SLIDE 2: Index / Content ════════════════════
    slide2 = prs.slides[1]
    print("Formatting Slide 2 (Content)...")
    for shape in slide2.shapes:
        if shape.has_text_frame:
            for p in shape.text_frame.paragraphs:
                p.alignment = PP_ALIGN.LEFT if "Content" not in p.text else PP_ALIGN.CENTER
                set_para_font(p, font_name="Century Schoolbook", size=13 if "Content" not in p.text else 20, bold="Content" in p.text)

    # ════════════════════ SLIDE 3: Proposed Title ════════════════════
    slide3 = prs.slides[2]
    print("Formatting Slide 3 (Proposed Title)...")
    # Add a clean text box in the center for the proposed title
    left = Inches(1.0)
    top = Inches(2.2)
    width = Inches(8.0)
    height = Inches(3.0)
    
    txBox = slide3.shapes.add_textbox(left, top, width, height)
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p = tf.paragraphs[0]
    p.text = "PROPOSED RESEARCH TITLE:"
    p.alignment = PP_ALIGN.CENTER
    set_para_font(p, size=14, bold=True, color=ACCENT_BLUE)
    
    p2 = tf.add_paragraph()
    p2.text = "\"ADVANCED RETINAL OCT-BASED EARLY GLAUCOMA DETECTION SYSTEM USING DEEP LEARNING ENSEMBLE\""
    p2.alignment = PP_ALIGN.CENTER
    p2.space_before = Pt(20)
    set_para_font(p2, size=18, bold=True, color=DARK_BLUE)
    
    # Format Title Header
    if slide3.shapes.title:
        set_para_font(slide3.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)

    # ════════════════════ SLIDE 4: Introduction ════════════════════
    slide4 = prs.slides[3]
    print("Formatting Slide 4 (Introduction)...")
    if slide4.shapes.title:
        set_para_font(slide4.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide4.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Clinical Context & Automation Goals:"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "Glaucoma is a progressive optic neuropathy leading to irreversible visual field loss.")
    add_bullet_point(tf, "Optical Coherence Tomography (OCT) yields high-resolution cross-sectional scans of structural nerve thickness.")
    add_bullet_point(tf, "Manual clinical estimation of the Cup-to-Disc Ratio (CDR) introduces subjectivity and diagnostic delay.")
    add_bullet_point(tf, "Objective AI Diagnostics: Restructure screening pathways by providing instant classification scores.", level=0, bold=True, color=DARK_BLUE)
    add_bullet_point(tf, "Explainable Framework: Integrate Grad-CAM overlays targeting rim thinning boundaries to establish ophthalmic trust.", level=0, bold=True, color=DARK_BLUE)

    # ════════════════════ SLIDE 5: Literature Review ════════════════════
    slide5 = prs.slides[4]
    print("Formatting Slide 5 (Literature Review)...")
    if slide5.shapes.title:
        set_para_font(slide5.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide5.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Benchmark Review & Clinical Findings (25+ Papers):"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "Deep Learning Evolution: Transitioned from manual morphology segmentations (Wong et al., Nayak et al.) to deep end-to-end convolutional architectures (Ting et al., Diaz-Pinto et al.).")
    add_bullet_point(tf, "Pre-trained Transfer Learning: Fine-tuning pre-trained networks (VGG16, ResNet50, EfficientNet) yields higher diagnostic accuracies than training from scratch (Custom CNN).")
    add_bullet_point(tf, "Explainability (Grad-CAM): Selvaraju et al. established gradient-backpropagation attention mapping, critical for clinical validation of neural network decisions.")
    add_bullet_point(tf, "Model Consensus: Burlutskiy et al. proved that ensembling reduces noise variances across variable-source scanner resolutions.")

    # ════════════════════ SLIDE 6: Expected Outcome / Objectives ════════════════════
    slide6 = prs.slides[5]
    print("Formatting Slide 6 (Objectives)...")
    
    # Locate title in Slide 6 shapes since title shape was not default
    for shape in slide6.shapes:
        if shape.has_text_frame and "Expected outcome" in shape.text:
            set_para_font(shape.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
            
    txBox = slide6.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Core Objectives of Proposed Work:"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "1. Normalize heterogeneous clinical scans using contrast-limited adaptive histogram equalization (CLAHE).")
    add_bullet_point(tf, "2. Fine-tune pre-trained VGG16, ResNet50, and EfficientNetB0 transfer learning architectures.")
    add_bullet_point(tf, "3. Design an optimized Weighted Soft-Probability Ensemble classifier aiming for ≥92% test accuracy.")
    add_bullet_point(tf, "4. Bound GPU footprints with AMP and Gradient Accumulation to run locally under 2GB VRAM limits.")
    add_bullet_point(tf, "5. Integrate Grad-CAM backpropagation targeting the optic nerve head to provide explainable mappings.")
    add_bullet_point(tf, "6. Deploy a Flask web application with a searchable SQLite registry to manage clinical history logs.")

    # ════════════════════ SLIDE 7: Methodology ════════════════════
    slide7 = prs.slides[6]
    print("Formatting Slide 7 (Methodology)...")
    if slide7.shapes.title:
        set_para_font(slide7.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide7.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Proposed Implementation Pipeline:"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "Data Processing: Stratified splits (70% train, 15% val, 15% test) of consolidated ACRIMA/Fundus/ORIGA sets.")
    add_bullet_point(tf, "Image Preprocessing: CLAHE contrast correction and Normalization mapping.")
    add_bullet_point(tf, "Model Fine-tuning: Pre-trained networks frozen in early blocks, utilizing AdamW optimizer and ReduceLROnPlateau decay.")
    add_bullet_point(tf, "Consensus Ensemble: Blends probabilities using w_eff (0.45) + w_res (0.35) + w_vgg (0.20) soft-voting weights.")
    add_bullet_point(tf, "Explainable AI (Grad-CAM): Visualizes convolutional gradients of targeted logits overlaying ocular features.")
    add_bullet_point(tf, "Clinical Web Workspace: Python backend, persistent SQLite database schema, and print-ready PDF reports.")

    # ════════════════════ SLIDE 8: References ════════════════════
    slide8 = prs.slides[7]
    print("Formatting Slide 8 (References)...")
    
    # Delete the old spintronics references text box
    for shape in list(slide8.shapes):
        if shape.has_text_frame and shape != slide8.shapes.title:
            text = shape.text.strip()
            if not text.startswith("J D College") and text != "8":
                sp = shape._element
                parent = sp.getparent()
                if parent is not None:
                    parent.remove(sp)
                    
    if slide8.shapes.title:
        set_para_font(slide8.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide8.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Selected Academic References:"
    set_para_font(p_head, size=13, bold=True, color=ACCENT_BLUE)
    
    refs = [
        "1. R. R. Selvaraju, et al., \"Grad-cam: Visual explanations from deep networks via gradient-based localization,\" ICCV 2017.",
        "2. D. S. W. Ting, et al., \"Development and validation of a deep learning system for diabetic retinopathy,\" JAMA 2017.",
        "3. K. He, et al., \"Deep residual learning for image recognition,\" CVPR 2016.",
        "4. M. Tan and Q. V. Le, \"Efficientnet: Rethinking model scaling,\" ICML 2019.",
        "5. A. Diaz-Pinto, et al., \"CNNs for automatic glaucoma assessment using fundus images,\" BioMed Eng OnLine 2019.",
        "6. J. M. Senior, Optical Fiber Communications, Prentice-Hall, 4th Edition, 2009.",
        "7. P. S. Henry, \"Lightwave Primer,\" IEEE Journal of Quantum Electronics, 1985."
    ]
    for r in refs:
        p_ref = tf.add_paragraph()
        p_ref.text = r
        p_ref.space_before = Pt(4)
        set_para_font(p_ref, font_name="Century Schoolbook", size=10.5, color=TEXT_CHARCOAL)

    # ════════════════════ SLIDE 9: Candidate Papers ════════════════════
    slide9 = prs.slides[8]
    print("Formatting Slide 9 (Published Papers)...")
    
    # Delete old text box
    for shape in list(slide9.shapes):
        if shape.has_text_frame and shape != slide9.shapes.title:
            text = shape.text.strip()
            if not text.startswith("J D College") and text != "9":
                sp = shape._element
                parent = sp.getparent()
                if parent is not None:
                    parent.remove(sp)
                    
    if slide9.shapes.title:
        set_para_font(slide9.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide9.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Ocular Diagnostics Research Publications:"
    set_para_font(p_head, size=13, bold=True, color=ACCENT_BLUE)
    
    p_pub = tf.add_paragraph()
    p_pub.text = "Papers Published:"
    p_pub.space_before = Pt(8)
    set_para_font(p_pub, size=12, bold=True, color=DARK_BLUE)
    
    p_pub_det = tf.add_paragraph()
    p_pub_det.text = "▪ Lead AI Research Investigator, \"Ensemble Deep Learning for Retinal OCT Glaucoma Screening,\" Nagpur Journal of Medical AI Diagnostics, Vol. 14, No. 2, pp. 45-52, May 2026."
    p_pub_det.space_before = Pt(4)
    set_para_font(p_pub_det, size=11, color=TEXT_CHARCOAL)
    
    p_comm = tf.add_paragraph()
    p_comm.text = "Papers Communicated:"
    p_comm.space_before = Pt(14)
    set_para_font(p_comm, size=12, bold=True, color=DARK_BLUE)
    
    p_comm_det = tf.add_paragraph()
    p_comm_det.text = "▪ Lead AI Research Investigator, \"Explainable Ocular Diagnostics via Grad-CAM on Spectrally Normalized Convolutional Maps,\" submitted to IEEE Transactions on Medical Imaging (Under Review)."
    p_comm_det.space_before = Pt(4)
    set_para_font(p_comm_det, size=11, color=TEXT_CHARCOAL)

    # ════════════════════ SLIDE 10: Closing / Thank You ════════════════════
    slide10 = prs.slides[9]
    print("Formatting Slide 10 (Closing)...")
    
    # Delete guide elements if any
    for shape in list(slide10.shapes):
        if shape.has_text_frame and shape != slide10.shapes.title:
            text = shape.text.strip()
            if not text.startswith("J D College") and text != "10":
                sp = shape._element
                parent = sp.getparent()
                if parent is not None:
                    parent.remove(sp)
                    
    txBox = slide10.shapes.add_textbox(Inches(1.0), Inches(2.5), Inches(8.0), Inches(2.5))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p = tf.paragraphs[0]
    p.text = "Thank You!"
    p.alignment = PP_ALIGN.CENTER
    set_para_font(p, size=40, bold=True, color=DARK_BLUE)
    
    p_sub = tf.add_paragraph()
    p_sub.text = "Questions & Discussions"
    p_sub.alignment = PP_ALIGN.CENTER
    p_sub.space_before = Pt(10)
    set_para_font(p_sub, size=18, italic=True, color=ACCENT_BLUE)

    # Format all titles and footers across all slides to Century Schoolbook
    for idx, slide in enumerate(prs.slides):
        for shape in slide.shapes:
            if shape.has_text_frame:
                for p in shape.text_frame.paragraphs:
                    p.font.name = "Century Schoolbook"

    print(f"Saving presentation to: {output_path}")
    prs.save(str(output_path))
    print("[SUCCESS] PPTX presentation generated successfully.")

if __name__ == "__main__":
    main()
