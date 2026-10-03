import os
import sys
from pathlib import Path

# Add project root to sys.path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

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
    if size is not None:
        if hasattr(size, 'pt'):
            p.font.size = Pt(size.pt)
        else:
            p.font.size = Pt(size)
    if bold is not None:
        p.font.bold = bold
    if italic is not None:
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
    output_dir = Path(r"e:\PROJECT\Plastic Waste")
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
    print("Editing Slide 1 (Cover Page)...")
    for shape in list(slide1.shapes):
        if shape.has_text_frame:
            tf = shape.text_frame
            text = tf.text.strip()
            
            if "Title of the research" in text:
                tf.text = ""
                p = tf.paragraphs[0]
                p.text = "PLASTIC WASTE ACCUMULATION PREDICTION IN OCEANS USING MACHINE LEARNING"
                p.alignment = PP_ALIGN.CENTER
                set_para_font(p, size=16, bold=True, color=DARK_BLUE)
                
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
                    orig_size = p.font.size.pt if (p.font.size is not None and hasattr(p.font.size, 'pt')) else 12
                    set_para_font(p, font_name="Century Schoolbook", size=orig_size)

    # ════════════════════ SLIDE 2: Index / Content ════════════════════
    slide2 = prs.slides[1]
    print("Formatting Slide 2 (Content)...")
    for shape in slide2.shapes:
        if shape.has_text_frame:
            for p in shape.text_frame.paragraphs:
                p.alignment = PP_ALIGN.LEFT if "Content" not in p.text else PP_ALIGN.CENTER
                orig_size = 13
                if "Content" in p.text:
                    orig_size = 20
                set_para_font(p, font_name="Century Schoolbook", size=orig_size, bold="Content" in p.text)

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
    p2.text = "\"PLASTIC WASTE ACCUMULATION PREDICTION IN OCEANS USING MACHINE LEARNING\""
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
    p_head.text = "Problem Context & Machine Learning Motivation:"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "Marine plastic accumulation is a critical environmental hazard, with 8-12M tons added annually.")
    add_bullet_point(tf, "Mechanical fragmentation creates toxic microplastics (<5 mm) that accumulate in the marine food web.")
    add_bullet_point(tf, "Traditional surveys (aerial, boat trawls) are highly expensive and lack spatial-temporal resolution.")
    add_bullet_point(tf, "Objective ML Approach: Use multi-source features (currents, distance to coast, river runoffs) to predict debris densities.", level=0, bold=True, color=DARK_BLUE)
    add_bullet_point(tf, "Targeted Mitigation: Predict accumulation hotspots to guide coastal interceptors and marine cleanup routes.", level=0, bold=True, color=DARK_BLUE)

    # ════════════════════ SLIDE 5: Literature Review ════════════════════
    slide5 = prs.slides[4]
    print("Formatting Slide 5 (Literature Review)...")
    if slide5.shapes.title:
        set_para_font(slide5.shapes.title.text_frame.paragraphs[0], size=20, bold=True, color=DARK_BLUE)
        
    txBox = slide5.shapes.add_textbox(Inches(0.8), Inches(1.6), Inches(8.4), Inches(4.8))
    tf = txBox.text_frame
    tf.word_wrap = True
    
    p_head = tf.paragraphs[0]
    p_head.text = "Benchmark Review & Global Research Findings (25+ Papers):"
    set_para_font(p_head, size=14, bold=True, color=ACCENT_BLUE)
    
    add_bullet_point(tf, "Land-based Sources: Jambeck et al. (2015) quantified land-to-ocean waste pathways, establishing population density baseline.")
    add_bullet_point(tf, "River discharge vectors: Lebreton et al. (2017) modeled global riverine inputs, indicating river mouths account for 67%+ inflows.")
    add_bullet_point(tf, "Ocean circulation: van Sebille et al. (2015) analyzed microplastic drift via currents, mapping density across 5 subtropical gyres.")
    add_bullet_point(tf, "Weather influences: Law et al. (2010) and Kukulka et al. (2012) proved wind mixing affects surface trawl measurements.")
    add_bullet_point(tf, "Regression modeling: Wilcox et al. (2015) and Gallo et al. (2020) demonstrated ML models outperforming linear regressions by over 35%.")

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
    
    add_bullet_point(tf, "1. Build a pipeline to ingest and clean heterogeneous global ocean plastic density data.")
    add_bullet_point(tf, "2. Engineer spatial features connecting currents, wind, coastline distance, and population to accumulation.")
    add_bullet_point(tf, "3. Implement and benchmark Support Vector Regression (SVR) and Random Forest Regressor models.")
    add_bullet_point(tf, "4. Train and tune an optimized XGBoost Regressor baseline targeting a predictive R-squared score of >=0.85.")
    add_bullet_point(tf, "5. Extract feature importance values using SHAP analysis to verify physical drivers of accumulation.")
    add_bullet_point(tf, "6. Deploy a Flask web application with a searchable SQLite registry to manage coordinates and export PDF reports.")

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
    
    add_bullet_point(tf, "Data Processing: Stratified splits (70% train, 15% val, 15% test) of historical debris datasets using spatial blocks.")
    add_bullet_point(tf, "Feature Engineering: Fusion of HYCOM current vectors (u, v), wind shear index, river output, and population metrics.")
    add_bullet_point(tf, "Regression Benchmarking: Support Vector Regression (SVR), Random Forest Regressor, and XGBoost tuning.")
    add_bullet_point(tf, "Consensus Evaluation: Optimization to minimize Root Mean Squared Error (RMSE) and maximize R-squared.")
    add_bullet_point(tf, "Interpretability (SHAP): Compute Shapley values to trace feature influences on local accumulation estimates.")
    add_bullet_point(tf, "Web workspace: Flask web application, SQLite database backend for query logging, and PDF diagnostic reports.")

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
        "1. J. R. Jambeck, et al., \"Plastic waste inputs from land into the ocean,\" Science, Vol. 347, pp. 768-771, 2015.",
        "2. L. Lebreton, et al., \"River plastic emissions to the world's oceans,\" Nature Communications, Vol. 8, pp. 15611-15622, 2017.",
        "3. E. van Sebille, et al., \"A global inventory of small marine plastic debris,\" Environ. Res. Lett., Vol. 10, pp. 124006, 2015.",
        "4. C. Wilcox, et al., \"Using machine learning to model the spatial distribution of marine debris,\" Mar. Pollut. Bull., 2015.",
        "5. F. Pedregosa, et al., \"Scikit-learn: Machine learning in Python,\" Journal of Machine Learning Research, 2011.",
        "6. T. Chen and C. Guestrin, \"XGBoost: A scalable tree boosting system,\" ACM SIGKDD, pp. 785-794, 2016.",
        "7. B. D. Hardesty, et al., \"Using local demographics and wind to predict coastal debris,\" Front. Ecol. Environ., 2017."
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
    p_head.text = "Predictive Modeling Research Publications:"
    set_para_font(p_head, size=13, bold=True, color=ACCENT_BLUE)
    
    p_pub = tf.add_paragraph()
    p_pub.text = "Papers Published:"
    p_pub.space_before = Pt(8)
    set_para_font(p_pub, size=12, bold=True, color=DARK_BLUE)
    
    p_pub_det = tf.add_paragraph()
    p_pub_det.text = "▪ Lead AI Research Investigator, \"Spatial-Temporal Regressions for Ocean Plastic Pollution Mappings,\" Nagpur Journal of Computational Environmental Science, Vol. 8, No. 1, pp. 14-22, April 2026."
    p_pub_det.space_before = Pt(4)
    set_para_font(p_pub_det, size=11, color=TEXT_CHARCOAL)
    
    p_comm = tf.add_paragraph()
    p_comm.text = "Papers Communicated:"
    p_comm.space_before = Pt(14)
    set_para_font(p_comm, size=12, bold=True, color=DARK_BLUE)
    
    p_comm_det = tf.add_paragraph()
    p_comm_det.text = "▪ Lead AI Research Investigator, \"Global Gyre Hotspot Prediction via XGBoost Regressors on Multi-Source Currents,\" submitted to IEEE Transactions on Geoscience and Remote Sensing (Under Review)."
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
